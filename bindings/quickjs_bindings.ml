open Ctypes

module C (F : Cstubs.FOREIGN) = struct
  open F

  let const x = x

  type jscontext

  let jscontext : jscontext structure typ = structure "JSContext"

  type jsruntime

  let jsruntime : jsruntime structure typ = structure "JSRuntime"

  type jsvalue_union

  let jsvalue_union : jsvalue_union union typ = union "JSValueUnion"

  let _ = field jsvalue_union "int32" int32_t

  let _ = field jsvalue_union "float64" double

  let _ = field jsvalue_union "ptr" (ptr void)

  let () = seal jsvalue_union

  type jsvalue

  let jsvalue : jsvalue structure typ = structure "JSValue"

  let _ = field jsvalue "u" jsvalue_union

  let _ = field jsvalue "tag" int64_t

  let () = seal jsvalue

  let js_new_runtime =
    (* JSRuntime *JS_NewRuntime(void) *)
    foreign "JS_NewRuntime" (void @-> returning (ptr jsruntime))

  let js_free_runtime =
    (* void JS_FreeRuntime(JSRuntime *rt) *)
    foreign "JS_FreeRuntime" (ptr jsruntime @-> returning void)

  let js_new_context =
    (* JSContext *JS_NewContext(JSRuntime *rt) *)
    foreign "JS_NewContext" (ptr jsruntime @-> returning (ptr jscontext))

  let js_free_context =
    (* void JS_FreeContext(JSContext *s) *)
    foreign "JS_FreeContext" (ptr jscontext @-> returning void)

  let js_eval =
    (* JSValue JS_Eval(JSContext *ctx, const char *input, size_t input_len, const char *filename, int eval_flags) *)
    foreign
      "JS_Eval"
      (ptr jscontext
      @-> string
      @-> size_t
      @-> string
      @-> int
      @-> returning jsvalue
      )
end
