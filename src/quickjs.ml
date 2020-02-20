module C = Quickjs_raw

type runtime = C.js_runtime Ctypes.structure Ctypes.ptr

type context = {
  rt: runtime;
  ctx: C.js_context Ctypes.structure Ctypes.ptr;
}

type value = {
  ctx: context;
  v: C.js_value Ctypes.structure;
}

type js_exn = value

type 'a or_js_exn = ('a, js_exn) result

(* --- *)

let new_runtime () : runtime =
  let rt = C.js_new_runtime () in
  let () = Gc.finalise (fun obj -> C.js_free_runtime obj) rt in
  rt

let new_context (rt : runtime) : context =
  let ctx = C.js_new_context rt in
  let r = { rt; ctx } in
  let () = Gc.finalise (fun (obj : context) -> C.js_free_context obj.ctx) r in
  r

let new_value (ctx : context) (v : C.js_value Ctypes.structure) : value =
  let o = { ctx; v } in
  Gc.finalise (fun (obj : value) -> C.js_free_value obj.ctx.ctx obj.v) o;
  o

let get_exception (ctx : context) : value =
  let v = C.js_get_exception ctx.ctx in
  new_value ctx v

module Value = struct
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

  let to_uint32 v : Unsigned.UInt32.t or_js_exn =
    let p = Ctypes.(allocate uint32_t Unsigned.UInt32.zero) in
    let f = C.js_to_uint32 in
    to_xxx v p f
end

let eval_unsafe (ctx : context) (script : string) : value =
  let len = Unsigned.Size_t.of_int (String.length script) in
  let v = C.js_eval ctx.ctx script len "input.js" 0 in
  new_value ctx v

let eval (ctx : context) (script : string) : value or_js_exn =
  let r = eval_unsafe ctx script in
  if Value.is_exception r then Error (get_exception ctx) else Ok r

let eval_once (script : string) : value or_js_exn =
  let ctx = new_runtime () |> new_context in
  eval ctx script
