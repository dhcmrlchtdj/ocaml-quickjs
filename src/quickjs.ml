module C = Bindings.Make (Stubs)

module Q : sig
  type runtime
  (** JSRuntime represents a Javascript runtime corresponding to an object heap.
    Several runtimes can exist at the same time but they cannot exchange objects.
    Inside a given runtime, no multi-threading is supported.
    *)

  val new_runtime : unit -> runtime

  (* --- *)

  type context
  (** JSContext represents a Javascript context (or Realm). Each JSContext has
    its own global objects and system objects. There can be several JSContexts
    per JSRuntime and they can share objects, similar to frames of the same
    origin sharing Javascript objects in a web browser.
    *)

  val new_context : runtime -> context

  (* --- *)

  type value
  (** JSValue represents a Javascript value which can be a primitive type or an
    object.
    *)

  val eval : context -> string -> (value, string) result
end = struct
  type runtime = C.js_runtime Ctypes.structure Ctypes.ptr

  let new_runtime () : runtime =
    let rt = C.js_new_runtime () in
    let () = Gc.finalise (fun rt -> C.js_free_runtime rt) rt in
    rt

  (* --- *)

  type context = {
    rt: runtime;
    ctx: C.js_context Ctypes.structure Ctypes.ptr;
  }

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

  let eval (ctx : context) (script : string) : (value, string) result =
    let len = Unsigned.Size_t.of_int (String.length script) in
    let v = C.js_eval ctx.ctx script len "input.js" 0 in
    Ok { ctx; v }
end

include Q
