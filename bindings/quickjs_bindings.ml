open Ctypes

module Make (F : Cstubs.FOREIGN) = struct
  open F

  (*
   * JSValue
   * JS_DupValue
   * JS_FreeValue
   * JS_NewCFunction
   * JS_SetPropertyFunctionList
   * JS_EXCEPTION
   * JS_GetException
   * JS_Eval
   * js_std_eval_binary
   * JS_NewClassID
   * JS_NewClass
   * JS_NewObjectClass
   * JS_GetOpaque
   * JS_SetOpaque
   * JS_SetClassProto
   * JS_NewRuntime2
   * JS_SetMaxStackSize
   * JS_SetInterruptHandler
   *)
  (* typedef struct JSObject JSObject; *)
  (* typedef struct JSClass JSClass; *)

  (* --- *)

  type js_context

  let js_context : js_context structure typ = structure "JSContext"

  (* --- *)

  type js_runtime

  let js_runtime : js_runtime structure typ = structure "JSRuntime"

  (* --- *)

  let js_class_id = uint32_t

  let js_atom = uint32_t

  let js_bool = int

  (* --- *)

  (* #else /* !JS_NAN_BOXING */ *)

  type js_value_union

  let js_value_union : js_value_union union typ = union "JSValueUnion"

  let _ = field js_value_union "int32" int32_t

  let _ = field js_value_union "float64" double

  let _ = field js_value_union "ptr" (ptr void)

  let () = seal js_value_union

  type js_value

  let js_value : js_value structure typ = structure "JSValue"

  let _ = field js_value "u" js_value_union

  let _ = field js_value "tag" int64_t

  let () = seal js_value

  let js_value_const = js_value

  (* --- *)

  let js_new_runtime =
    (* JSRuntime *JS_NewRuntime(void) *)
    foreign "JS_NewRuntime" (void @-> returning (ptr js_runtime))

  let js_free_runtime =
    (* void JS_FreeRuntime(JSRuntime *rt) *)
    foreign "JS_FreeRuntime" (ptr js_runtime @-> returning void)

  let js_set_runtime_info =
    (* void JS_SetRuntimeInfo(JSRuntime *rt, const char *info); *)
    foreign "JS_SetRuntimeInfo" (ptr js_runtime @-> string @-> returning void)

  let js_set_memory_limit =
    (* void JS_SetMemoryLimit(JSRuntime *rt, size_t limit); *)
    foreign "JS_SetMemoryLimit" (ptr js_runtime @-> size_t @-> returning void)

  let js_set_gc_threshold =
    (* void JS_SetGCThreshold(JSRuntime *rt, size_t gc_threshold); *)
    foreign "JS_SetGCThreshold" (ptr js_runtime @-> size_t @-> returning void)

  (* --- *)

  let js_new_context =
    (* JSContext *JS_NewContext(JSRuntime *rt) *)
    foreign "JS_NewContext" (ptr js_runtime @-> returning (ptr js_context))

  let js_free_context =
    (* void JS_FreeContext(JSContext *s) *)
    foreign "JS_FreeContext" (ptr js_context @-> returning void)

  let js_get_runtime =
    (* JSRuntime *JS_GetRuntime(JSContext *ctx); *)
    foreign "JS_GetRuntime" (ptr js_context @-> returning (ptr js_runtime))

  let js_set_max_stack_size =
    (* void JS_SetMaxStackSize(JSContext *ctx, size_t stack_size); *)
    foreign "JS_SetMaxStackSize" (ptr js_context @-> size_t @-> returning void)

  let js_set_class_proto =
    (* void JS_SetClassProto(JSContext *ctx, JSClassID class_id, JSValue obj); *)
    foreign
      "JS_SetClassProto"
      (ptr js_context @-> js_class_id @-> js_value @-> returning void)

  let js_get_class_proto =
    (* JSValue JS_GetClassProto(JSContext *ctx, JSClassID class_id); *)
    foreign
      "JS_GetClassProto"
      (ptr js_context @-> js_class_id @-> returning js_value)

  (* --- *)

  let js_eval =
    (* JSValue JS_Eval(JSContext *ctx, const char *input, size_t input_len, const char *filename, int eval_flags) *)
    foreign
      "JS_Eval"
      (ptr js_context
      @-> string
      @-> size_t
      @-> string
      @-> int
      @-> returning js_value
      )
end
