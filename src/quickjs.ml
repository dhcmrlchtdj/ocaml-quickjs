module C = Quickjs_raw

(* --- *)

type runtime = C.js_runtime Ctypes.structure Ctypes.ptr

type context = {
  rt: runtime;
  ctx: C.js_context Ctypes.structure Ctypes.ptr;
}

type bytecode = {
  ctx: context;
  bc: C.js_value Ctypes.structure;
}

type value = {
  ctx: context;
  v: C.js_value Ctypes.structure;
}

type js_exn = value

type 'a or_js_exn = ('a, js_exn) result

(* --- *)

let build_value (ctx : context) (v : C.js_value Ctypes.structure) : value =
  let o = { ctx; v } in
  Gc.finalise (fun (obj : value) -> C.js_free_value obj.ctx.ctx obj.v) o;
  o

let build_bytecode (ctx : context) (bc : C.js_value Ctypes.structure) : bytecode
  =
  let o = { ctx; bc } in
  Gc.finalise (fun (obj : bytecode) -> C.js_free_value obj.ctx.ctx obj.bc) o;
  o

let new_runtime () : runtime =
  let rt = C.js_new_runtime () in
  let () = Gc.finalise (fun obj -> C.js_free_runtime obj) rt in
  rt

let new_context (rt : runtime) : context =
  let ctx = C.js_new_context rt in
  let r = { rt; ctx } in
  let () = Gc.finalise (fun (obj : context) -> C.js_free_context obj.ctx) r in
  r

let set_memory_limit = C.js_set_memory_limit

let set_gc_threshold = C.js_set_gc_threshold

let set_max_stack_size (ctx : context) = C.js_set_max_stack_size ctx.ctx

let get_exception (ctx : context) : value =
  let v = C.js_get_exception ctx.ctx in
  build_value ctx v

module Value = struct
  let convert_to_string v : value =
    let new_v = C.js_to_string v.ctx.ctx v.v in
    build_value v.ctx new_v

  let is_uninitialized v = C.js_is_uninitialized v.v = 1

  let is_null v = C.js_is_null v.v = 1

  let is_undefined v = C.js_is_undefined v.v = 1

  let is_bool v = C.js_is_bool v.v = 1

  let is_number v = C.js_is_number v.v = 1

  let is_string v = C.js_is_string v.v = 1

  let is_symbol v = C.js_is_symbol v.v = 1

  let is_array v = C.js_is_array v.ctx.ctx v.v = 1

  let is_object v = C.js_is_object v.v = 1

  let is_function v = C.js_is_function v.ctx.ctx v.v = 1

  let is_constructor v = C.js_is_constructor v.ctx.ctx v.v = 1

  let is_error v = C.js_is_error v.ctx.ctx v.v = 1

  let is_exception v = C.js_is_exception v.v = 1

  let is_big_int v = C.js_is_big_int v.ctx.ctx v.v = 1

  let is_big_float v = C.js_is_big_float v.v = 1

  let is_big_decimal v = C.js_is_big_decimal v.v = 1

  let is_instance_of v1 v2 =
    if v1.ctx == v2.ctx
    then C.js_is_instance_of v1.ctx.ctx v1.v v2.v = 1
    else false

  let to_string v : string =
    let r = C.js_to_c_string v.ctx.ctx v.v in
    r

  let to_bool v : bool or_js_exn =
    let r = C.js_to_bool v.ctx.ctx v.v in
    match r with
      | -1 -> Error (get_exception v.ctx)
      | 0 -> Ok false
      | _ -> Ok true

  let to_xxx v p f =
    let r = f v.ctx.ctx p v.v in
    if r = 0 then Ok Ctypes.(!@p) else Error (get_exception v.ctx)

  let to_int32 v =
    let p = Ctypes.(allocate int32_t 0l) in
    let f = C.js_to_int32 in
    to_xxx v p f

  let to_int64 v =
    let p = Ctypes.(allocate int64_t 0L) in
    let f = if is_big_int v then C.js_to_bigint64 else C.js_to_int64 in
    to_xxx v p f

  let to_float v =
    let p = Ctypes.(allocate double 0.0) in
    let f = C.js_to_float64 in
    to_xxx v p f

  let to_uint32 v =
    let p = Ctypes.(allocate uint32_t Unsigned.UInt32.zero) in
    let f = C.js_to_uint32 in
    to_xxx v p f
end

let check_exception (r : value) : value or_js_exn =
  if Value.is_exception r then Error (get_exception r.ctx) else Ok r

(* --- *)

let variants2flag = function
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
    let f = variants2flag typ in
    let f = if compile_only then f lor variants2flag `COMPILE_ONLY else f in
    let f =
      List.fold_left (fun acc curr -> acc lor variants2flag curr) f flags
    in
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
  let v = C.js_eval ctx.ctx script len "input.js" flag in
  build_value ctx v

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
  let v = raw_eval true typ flags ctx script in
  let v = check_exception v in
  Result.map (fun v -> build_bytecode v.ctx v.v) v

let execute (bc : bytecode) : value or_js_exn =
  let ctx = bc.ctx in
  let r = C.js_eval_function ctx.ctx bc.bc in
  let r = build_value ctx r in
  check_exception r

(* --- *)

module Raw = struct
  let of_runtime (rt : runtime) = rt

  let of_context (ctx : context) = ctx.ctx

  let of_value (v : value) = v.v

  let of_bytecode (bc : bytecode) = bc.bc
end
