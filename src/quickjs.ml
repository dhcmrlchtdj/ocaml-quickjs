module C = Quickjs_raw

(* --- *)

type runtime = C.js_runtime_ptr

type context = {
  rt: runtime;
  ctx: C.js_context_ptr;
}

type bytecode = {
  ctx: context;
  bc: C.js_value;
}

type value = {
  ctx: context;
  jsval: C.js_value;
}

type js_exn = value

type 'a or_js_exn = ('a, js_exn) result

(* --- *)

let get_raw_runtime (rt : runtime) = rt

let get_raw_context (ctx : context) = ctx.ctx

let get_raw_value o = o.jsval

let get_raw_bytecode bc = bc.bc

(* --- *)

let build_value (ctx : context) (jsval : C.js_value) : value =
  let o = { ctx; jsval } in
  Gc.finalise (fun { ctx; jsval } -> C.js_free_value ctx.ctx jsval) o;
  o

let build_bytecode (ctx : context) (bc : C.js_value) : bytecode =
  let o = { ctx; bc } in
  Gc.finalise (fun { ctx; bc } -> C.js_free_value ctx.ctx bc) o;
  o

(* --- *)

let new_runtime () : runtime =
  let rt = C.js_new_runtime () in
  let () = Gc.finalise (fun obj -> C.js_free_runtime obj) rt in
  rt

let set_memory_limit = C.js_set_memory_limit

let set_gc_threshold = C.js_set_gc_threshold

type interrupt_handler = runtime -> bool

let set_interrupt_handler rt (handler : interrupt_handler) =
  let callback runtime _opaque = if handler runtime then 0 else 1 in
  let null_opaque = Ctypes.(to_voidp null) in
  C.js_set_interrupt_handler rt callback null_opaque

(* --- *)

let new_context rt : context =
  let ctx = { rt; ctx = C.js_new_context rt } in
  let () = Gc.finalise (fun (obj : context) -> C.js_free_context obj.ctx) ctx in
  ctx

let set_max_stack_size (ctx : context) = C.js_set_max_stack_size ctx.ctx

let get_runtime ctx = ctx.rt

(* --- *)

let get_exception (ctx : context) : value =
  let jsval = C.js_get_exception ctx.ctx in
  build_value ctx jsval

let check_exception o : value or_js_exn =
  if C.js_is_exception o.jsval = 1 then Error (get_exception o.ctx) else Ok o

module Value = struct
  let convert_to_string o : value =
    let new_o = C.js_to_string o.ctx.ctx o.jsval in
    build_value o.ctx new_o

  let is_uninitialized o = C.js_is_uninitialized o.jsval = 1

  let is_null o = C.js_is_null o.jsval <> 0

  let is_undefined o = C.js_is_undefined o.jsval <> 0

  let is_bool o = C.js_is_bool o.jsval <> 0

  let is_number o = C.js_is_number o.jsval <> 0

  let is_string o = C.js_is_string o.jsval <> 0

  let is_symbol o = C.js_is_symbol o.jsval <> 0

  let is_array o = C.js_is_array o.ctx.ctx o.jsval <> 0

  let is_object o = C.js_is_object o.jsval <> 0

  let is_function o = C.js_is_function o.ctx.ctx o.jsval <> 0

  let is_constructor o = C.js_is_constructor o.ctx.ctx o.jsval <> 0

  let is_error o = C.js_is_error o.ctx.ctx o.jsval <> 0

  let is_exception o = C.js_is_exception o.jsval <> 0

  let is_big_int o = C.js_is_big_int o.ctx.ctx o.jsval <> 0

  let is_big_float o = C.js_is_big_float o.jsval <> 0

  let is_big_decimal o = C.js_is_big_decimal o.jsval <> 0

  let is_instance_of o1 o2 =
    if o1.ctx == o2.ctx
    then C.js_is_instance_of o1.ctx.ctx o1.jsval o2.jsval <> 0
    else false

  let to_string o : string option =
    let rec aux (buf : Buffer.t) (char_ptr : char Ctypes.ptr) : string =
      let ch = Ctypes.(!@char_ptr) in
      if ch = '\000'
      then Buffer.contents buf
      else (
        Buffer.add_char buf ch;
        aux buf Ctypes.(char_ptr +@ 1)
      )
    in
    let cstring = C.js_to_c_string o.ctx.ctx o.jsval in
    if Ctypes.is_null cstring
    then None
    else (
      let ostring = aux (Buffer.create 64) cstring in
      let () = C.js_free_c_string o.ctx.ctx cstring in
      Some ostring
    )

  let to_bool o : bool or_js_exn =
    let r = C.js_to_bool o.ctx.ctx o.jsval in
    match r with
      | -1 -> Error (get_exception o.ctx)
      | 0 -> Ok false
      | _ -> Ok true

  let to_xxx o ptr set_ptr =
    let xxx = set_ptr o.ctx.ctx ptr o.jsval in
    if xxx = 0 then Ok (Ctypes.( !@ ) ptr) else Error (get_exception o.ctx)

  let to_int32 o =
    let ptr = Ctypes.(allocate int32_t 0l) in
    to_xxx o ptr C.js_to_int32

  let to_int64 o =
    let ptr = Ctypes.(allocate int64_t 0L) in
    let f = if is_big_int o then C.js_to_bigint64 else C.js_to_int64 in
    to_xxx o ptr f

  let to_float o =
    let ptr = Ctypes.(allocate double 0.0) in
    to_xxx o ptr C.js_to_float64

  let to_uint32 o =
    let ptr = Ctypes.(allocate uint32_t Unsigned.UInt32.zero) in
    to_xxx o ptr C.js_to_uint32
end

(* --- *)

let get_flag = function
  | `GLOBAL -> C.define_JS_EVAL_TYPE_GLOBAL
  | `MODULE -> C.define_JS_EVAL_TYPE_MODULE
  | `STRICT -> C.define_JS_EVAL_FLAG_STRICT
  | `STRIP -> C.define_JS_EVAL_FLAG_STRIP
  | `BACKTRACE_BARRIER -> C.define_JS_EVAL_FLAG_BACKTRACE_BARRIER
  | `COMPILE_ONLY -> C.define_JS_EVAL_FLAG_COMPILE_ONLY

type eval_type =
  [ `GLOBAL
  | `MODULE
  ]

type eval_flag =
  [ `STRICT
  | `STRIP
  | `BACKTRACE_BARRIER
  ]

let raw_eval
    (compile_only : bool)
    (typ : eval_type option)
    (flags : eval_flag list option)
    (ctx : context option)
    (script : string)
    : value
  =
  let build_flag typ flags compile_only =
    let f = get_flag typ in
    let f = if compile_only then f lor get_flag `COMPILE_ONLY else f in
    let f = List.fold_left (fun acc curr -> acc lor get_flag curr) f flags in
    f
  in
  let get_or_default default opt =
    match opt with
      | Some x -> x
      | None -> Lazy.force default
  in
  let typ = get_or_default (lazy `GLOBAL) typ in
  let flags = get_or_default (lazy []) flags in
  let ctx = get_or_default (lazy (new_runtime () |> new_context)) ctx in
  let flag = build_flag typ flags compile_only in
  let len = Unsigned.Size_t.of_int (String.length script) in
  let jsval = C.js_eval ctx.ctx script len "input.js" flag in
  build_value ctx jsval

let eval_unsafe
    ?(typ : eval_type option)
    ?(flags : eval_flag list option)
    ?(ctx : context option)
    (script : string)
    : value
  =
  raw_eval false typ flags ctx script

let eval
    ?(typ : eval_type option)
    ?(flags : eval_flag list option)
    ?(ctx : context option)
    (script : string)
    : value or_js_exn
  =
  check_exception (raw_eval false typ flags ctx script)

let compile
    ?(typ : eval_type option)
    ?(flags : eval_flag list option)
    ?(ctx : context option)
    (script : string)
    : bytecode or_js_exn
  =
  let o = raw_eval true typ flags ctx script in
  let o = check_exception o in
  Result.map (fun o -> build_bytecode o.ctx o.jsval) o

let execute (bc : bytecode) : value or_js_exn =
  let ctx = bc.ctx in
  let r = C.js_eval_function ctx.ctx bc.bc in
  let r = build_value ctx r in
  check_exception r
