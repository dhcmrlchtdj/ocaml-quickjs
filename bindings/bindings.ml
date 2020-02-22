open Ctypes

module type S_BOXING_OR_NOT = sig
  type js_value

  val js_value : js_value typ
end

module JS_NAN_BOXING : S_BOXING_OR_NOT = struct
  type js_value = Unsigned.uint64

  let js_value = uint64_t
end

module NOT_JS_NAN_BOXING : S_BOXING_OR_NOT = struct
  type js_value_union

  let js_value_union : js_value_union union typ = union "JSValueUnion"

  let _ = field js_value_union "int32" int32_t

  let _ = field js_value_union "float64" double

  let _ = field js_value_union "ptr" (ptr void)

  let () = seal js_value_union

  type _js_value

  type js_value = _js_value structure

  let js_value : js_value typ = structure "JSValue"

  let _ = field js_value "u" js_value_union

  let _ = field js_value "tag" int64_t

  let () = seal js_value
end

let box_or_not : (module S_BOXING_OR_NOT) =
  if Constants.define_JS_NAN_BOXING
  then
    ( module struct
      include JS_NAN_BOXING
    end
    )
  else
    ( module struct
      include NOT_JS_NAN_BOXING
    end
    )

module BOXING_OR_NOT = (val box_or_not : S_BOXING_OR_NOT)

module Make (F : Cstubs.FOREIGN) = struct
  open F

  (* --- *)

  include Constants

  (* --- *)

  type _js_runtime

  type js_runtime = _js_runtime structure

  type js_runtime_ptr = js_runtime ptr

  let js_runtime : js_runtime typ = structure "JSRuntime"

  (* --- *)

  type _js_context

  type js_context = _js_context structure

  type js_context_ptr = js_context ptr

  let js_context : js_context typ = structure "JSContext"

  (* --- *)

  let js_class_id = uint32_t

  let js_bool = int

  (* --- *)

  type js_value = BOXING_OR_NOT.js_value

  let js_value = BOXING_OR_NOT.js_value

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

  (* --- *)

  let js_free_value =
    (* void JS_FreeValue(JSContext *ctx, JSValue v) *)
    foreign "JS_FreeValue" (ptr js_context @-> js_value @-> returning void)

  let js_free_value_rt =
    (* void JS_FreeValueRT(JSRuntime *rt, JSValue v) *)
    foreign "JS_FreeValueRT" (ptr js_runtime @-> js_value @-> returning void)

  let js_dup_value =
    (* JSValue JS_DupValue(JSContext *ctx, JSValueConst v) *)
    foreign
      "JS_DupValue"
      (ptr js_context @-> js_value_const @-> returning js_value)

  let js_dup_value_rt =
    (* JSValue JS_DupValueRT(JSRuntime *rt, JSValueConst v) *)
    foreign
      "JS_DupValueRT"
      (ptr js_runtime @-> js_value_const @-> returning js_value)

  (* --- *)

  (*
  JS_BOOL JS_IsUninitialized(JSValueConst v)
  JS_BOOL JS_IsError(JSContext *ctx, JSValueConst val);
  JS_BOOL JS_IsException(JSValueConst v)
  JS_BOOL JS_IsNull(JSValueConst v)
  JS_BOOL JS_IsUndefined(JSValueConst v)
  JS_BOOL JS_IsBool(JSValueConst v)
  JS_BOOL JS_IsNumber(JSValueConst v)
  JS_BOOL JS_IsString(JSValueConst v)
  JS_BOOL JS_IsSymbol(JSValueConst v)
  int JS_IsArray(JSContext *ctx, JSValueConst val);
  JS_BOOL JS_IsObject(JSValueConst v)
  JS_BOOL JS_IsFunction(JSContext* ctx, JSValueConst val);
  JS_BOOL JS_IsConstructor(JSContext* ctx, JSValueConst val);
  int JS_IsInstanceOf(JSContext *ctx, JSValueConst val, JSValueConst obj);
  JS_BOOL JS_IsBigInt(JSContext *ctx, JSValueConst v)
  JS_BOOL JS_IsBigFloat(JSValueConst v)
  JS_BOOL JS_IsBigDecimal(JSValueConst v)
  *)

  let js_is_uninitialized =
    foreign "JS_IsUninitialized" (js_value_const @-> returning js_bool)

  let js_is_error =
    foreign
      "JS_IsError"
      (ptr js_context @-> js_value_const @-> returning js_bool)

  let js_is_exception =
    foreign "JS_IsException" (js_value_const @-> returning js_bool)

  let js_is_null = foreign "JS_IsNull" (js_value_const @-> returning js_bool)

  let js_is_undefined =
    foreign "JS_IsUndefined" (js_value_const @-> returning js_bool)

  let js_is_bool = foreign "JS_IsBool" (js_value_const @-> returning js_bool)

  let js_is_number = foreign "JS_IsNumber" (js_value_const @-> returning js_bool)

  let js_is_string = foreign "JS_IsString" (js_value_const @-> returning js_bool)

  let js_is_symbol = foreign "JS_IsSymbol" (js_value_const @-> returning js_bool)

  let js_is_array =
    foreign
      "JS_IsArray"
      (ptr js_context @-> js_value_const @-> returning js_bool)

  let js_is_object = foreign "JS_IsObject" (js_value_const @-> returning js_bool)

  let js_is_function =
    foreign
      "JS_IsFunction"
      (ptr js_context @-> js_value_const @-> returning js_bool)

  let js_is_constructor =
    foreign
      "JS_IsConstructor"
      (ptr js_context @-> js_value_const @-> returning js_bool)

  let js_is_instance_of =
    foreign
      "JS_IsInstanceOf"
      (ptr js_context
      @-> js_value_const
      @-> js_value_const
      @-> returning js_bool
      )

  let js_is_big_int =
    foreign
      "JS_IsBigInt"
      (ptr js_context @-> js_value_const @-> returning js_bool)

  let js_is_big_float =
    foreign "JS_IsBigFloat" (js_value_const @-> returning js_bool)

  let js_is_big_decimal =
    foreign "JS_IsBigDecimal" (js_value_const @-> returning js_bool)

  (* --- *)

  (*
  int JS_ToBool(JSContext *ctx, JSValueConst val); /* return -1 for JS_EXCEPTION */
  int JS_ToInt32(JSContext *ctx, int32_t *pres, JSValueConst val);
  int JS_ToUint32(JSContext *ctx, uint32_t *pres, JSValueConst val)
  int JS_ToInt64(JSContext *ctx, int64_t *pres, JSValueConst val);
  int JS_ToBigInt64(JSContext *ctx, int64_t *pres, JSValueConst val);
  int JS_ToFloat64(JSContext *ctx, double *pres, JSValueConst val);

  JSValue JS_ToString(JSContext *ctx, JSValueConst val);

  const char *JS_ToCString(JSContext *ctx, JSValueConst val1)
  void JS_FreeCString(JSContext *ctx, const char *ptr);
  *)

  let js_to_bool =
    foreign "JS_ToBool" (ptr js_context @-> js_value_const @-> returning int)

  let js_to_int32 =
    foreign
      "JS_ToInt32"
      (ptr js_context @-> ptr int32_t @-> js_value_const @-> returning int)

  let js_to_uint32 =
    foreign
      "JS_ToUint32"
      (ptr js_context @-> ptr uint32_t @-> js_value_const @-> returning int)

  let js_to_int64 =
    foreign
      "JS_ToInt64"
      (ptr js_context @-> ptr int64_t @-> js_value_const @-> returning int)

  let js_to_float64 =
    foreign
      "JS_ToFloat64"
      (ptr js_context @-> ptr double @-> js_value_const @-> returning int)

  let js_to_bigint64 =
    foreign
      "JS_ToBigInt64"
      (ptr js_context @-> ptr int64_t @-> js_value_const @-> returning int)

  let js_to_string =
    foreign
      "JS_ToString"
      (ptr js_context @-> js_value_const @-> returning js_value)

  let js_to_c_string =
    foreign
      "JS_ToCString"
      (ptr js_context @-> js_value_const @-> returning string)

  let js_free_c_string =
    foreign "JS_FreeCString" (ptr js_context @-> string @-> returning void)

  (* --- *)

  let js_get_exception =
    (* JSValue JS_GetException(JSContext *ctx); *)
    foreign "JS_GetException" (ptr js_context @-> returning js_value)

  let js_throw =
    (* JSValue JS_Throw(JSContext *ctx, JSValue obj); *)
    foreign "JS_Throw" (ptr js_context @-> js_value @-> returning js_value)

  (* --- *)

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

  let js_new_class_id =
    (* JSClassID JS_NewClassID(JSClassID *pclass_id); *)
    foreign "JS_NewClassID" (ptr js_class_id @-> returning js_class_id)

  let js_new_object_proto_class =
    (* JSValue JS_NewObjectProtoClass(JSContext *ctx, JSValueConst proto, JSClassID class_id); *)
    foreign
      "JS_NewObjectProtoClass"
      (ptr js_context @-> js_value_const @-> js_class_id @-> returning js_value)

  let js_new_object_class =
    (* JSValue JS_NewObjectClass(JSContext *ctx, int class_id); *)
    foreign "JS_NewObjectClass" (ptr js_context @-> int @-> returning js_value)

  let js_new_object_proto =
    (* JSValue JS_NewObjectProto(JSContext *ctx, JSValueConst proto); *)
    foreign
      "JS_NewObjectProto"
      (ptr js_context @-> js_value_const @-> returning js_value)

  let js_new_object =
    (* JSValue JS_NewObject(JSContext *ctx); *)
    foreign "JS_NewObject" (ptr js_context @-> returning js_value)

  let js_set_opaque =
    (* void JS_SetOpaque(JSValue obj, void *opaque); *)
    foreign "JS_SetOpaque" (js_value @-> ptr void @-> returning void)

  let js_get_opaque =
    (* void *JS_GetOpaque(JSValueConst obj, JSClassID class_id); *)
    foreign
      "JS_GetOpaque"
      (js_value_const @-> js_class_id @-> returning (ptr void))

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

  let js_eval_function =
    (* JSValue JS_EvalFunction(JSContext *ctx, JSValue fun_obj); *)
    foreign
      "JS_EvalFunction"
      (ptr js_context @-> js_value @-> returning js_value)

  (* --- *)

  (*
  let js_c_function =
    (* typedef JSValue JSCFunction(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv); *)
    Foreign.funptr
      Ctypes.(
        ptr js_context
        @-> js_value_const
        @-> int
        @-> ptr js_value_const
        @-> returning js_value)

  let js_new_c_function =
    (* JSValue JS_NewCFunction(JSContext *ctx, JSCFunction *func, const char *name, int length) *)
    foreign
      "JS_NewCFunction"
      (ptr js_context
      @-> js_c_function
      @-> string
      @-> int
      @-> returning js_value
      )
  *)

  (*
  type js_c_function_list_entry

  let js_c_function_list_entry : js_c_function_list_entry structure typ =
    structure "JSCFunctionListEntry"

  let js_set_property_function_list =
    (* void JS_SetPropertyFunctionList(JSContext *ctx, JSValueConst obj, const JSCFunctionListEntry *tab, int len); *)
    foreign
      "JS_SetPropertyFunctionList"
      (ptr js_context
      @-> js_value_const
      @-> ptr js_c_function_list_entry
      @-> int
      @-> returning void
      )
  *)

  (* --- *)

  let js_interrupt_handler =
    (* typedef int JSInterruptHandler(JSRuntime *rt, void *opaque); *)
    Foreign.funptr Ctypes.(ptr js_runtime @-> ptr void @-> returning int)

  let js_set_interrupt_handler =
    (* void JS_SetInterruptHandler(JSRuntime *rt, JSInterruptHandler *cb, void *opaque); *)
    foreign
      "JS_SetInterruptHandler"
      (ptr js_runtime @-> js_interrupt_handler @-> ptr void @-> returning void)
end
