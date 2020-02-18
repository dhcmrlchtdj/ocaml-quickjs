module C = Quickjs_bindings.Make (Quickjs_stubs)

type runtime = C.jsruntime Ctypes.structure Ctypes.ptr

let new_runtime () : runtime =
  let rt = C.js_new_runtime () in
  let () = Gc.finalise (fun rt -> C.js_free_runtime rt) rt in
  rt

type context = {
  rt: runtime;
  ctx: C.jscontext Ctypes.structure Ctypes.ptr;
}

let new_context (rt : runtime) : context =
  let ctx = C.js_new_context rt in
  let () = Gc.finalise (fun c -> C.js_free_context c) ctx in
  { rt; ctx }

type value = C.jsvalue Ctypes.structure

let eval (ctx : context) (script : string) : value =
  let len = Unsigned.Size_t.of_int (String.length script) in
  let r = C.js_eval ctx.ctx script len "" 0 in
  r
