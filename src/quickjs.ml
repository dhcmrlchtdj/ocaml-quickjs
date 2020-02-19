module C = Bindings.Make (Stubs)

type runtime = C.js_runtime Ctypes.structure Ctypes.ptr
(** JSRuntime represents a Javascript runtime corresponding to an object heap.
    Several runtimes can exist at the same time but they cannot exchange objects.
    Inside a given runtime, no multi-threading is supported.
    *)

let new_runtime () : runtime =
  let rt = C.js_new_runtime () in
  let () = Gc.finalise (fun rt -> C.js_free_runtime rt) rt in
  rt

(* --- *)

type context = {
  rt: runtime;
  ctx: C.js_context Ctypes.structure Ctypes.ptr;
}
(** JSContext represents a Javascript context (or Realm). Each JSContext has
    its own global objects and system objects. There can be several JSContexts
    per JSRuntime and they can share objects, similar to frames of the same
    origin sharing Javascript objects in a web browser.
    *)

let new_context (rt : runtime) : context =
  let ctx = C.js_new_context rt in
  let () = Gc.finalise (fun c -> C.js_free_context c) ctx in
  { rt; ctx }

(* --- *)

type value = {
  ctx: context;
  v: C.js_value Ctypes.structure;
}

(* --- *)

let get_exception (ctx : context) : string option =
  let ctx = ctx.ctx in
  let err = C.js_get_exception ctx in
  let is_exn = C.js_is_exception err = 1 in
  if is_exn then Some (C.js_to_c_string ctx err) else None

let get_exception_exn (ctx : context) : string = get_exception ctx |> Option.get

(* --- *)

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

  let is_exception v = C.js_is_exception v.v = 1

  let is_big_int v = C.js_is_big_int v.ctx.ctx v.v = 1

  let is_big_float v = C.js_is_big_float v.v = 1

  let is_big_decimal v = C.js_is_big_decimal v.v = 1

  let is_instance_of v1 v2 =
    if v1.ctx == v2.ctx
    then C.js_is_instance_of v1.ctx.ctx v1.v v2.v = 1
    else false

  let to_string v : (string, string) result =
    let r = C.js_to_c_string v.ctx.ctx v.v in
    Ok r

  let to_bool v : (bool, string) result =
    let r = C.js_to_bool v.ctx.ctx v.v in
    match r with
      | 0 -> Ok false
      | 1 -> Ok true
      | _ -> Error (get_exception_exn v.ctx)

  let to_int32 v : (int32, string) result =
    let p = Ctypes.(allocate int32_t 0l) in
    let r = C.js_to_int32 v.ctx.ctx p v.v in
    if r >= 0 then Ok Ctypes.(!@p) else Error (get_exception_exn v.ctx)

  let to_uint32 v : (Unsigned.UInt32.t, string) result =
    let p = Ctypes.(allocate uint32_t Unsigned.UInt32.zero) in
    let r = C.js_to_uint32 v.ctx.ctx p v.v in
    if r >= 0 then Ok Ctypes.(!@p) else Error (get_exception_exn v.ctx)

  let to_int64 v : (int64, string) result =
    let p = Ctypes.(allocate int64_t 0L) in
    let r = C.js_to_int64 v.ctx.ctx p v.v in
    if r >= 0 then Ok Ctypes.(!@p) else Error (get_exception_exn v.ctx)

  let to_float v : (float, string) result =
    let p = Ctypes.(allocate double 0.0) in
    let r = C.js_to_float64 v.ctx.ctx p v.v in
    if r >= 0 then Ok Ctypes.(!@p) else Error (get_exception_exn v.ctx)

  let to_big_int64 v : (int64, string) result =
    let p = Ctypes.(allocate int64_t 0L) in
    let r = C.js_to_big_int64 v.ctx.ctx p v.v in
    if r >= 0 then Ok Ctypes.(!@p) else Error (get_exception_exn v.ctx)
end

(* --- *)

let eval (ctx : context) (script : string) : (value, string) result =
  let len = Unsigned.Size_t.of_int (String.length script) in
  let v = C.js_eval ctx.ctx script len "input.js" 0 in
  let r = { ctx; v } in
  if Value.is_exception r then Error (get_exception_exn ctx) else Ok r

let eval_once (script : string) : (value, string) result =
  let ctx = new_runtime () |> new_context in
  eval ctx script
