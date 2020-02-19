module C : sig
  type js_runtime = Bindings.Make(Quickjs__.Stubs).js_runtime

  val js_runtime : js_runtime Ctypes.structure Ctypes.typ

  type js_context = Bindings.Make(Quickjs__.Stubs).js_context

  val js_context : js_context Ctypes.structure Ctypes.typ

  val js_class_id : Unsigned.uint32 Ctypes.typ

  val js_bool : int Ctypes.typ

  type js_value_union = Bindings.Make(Quickjs__.Stubs).js_value_union

  val js_value_union : js_value_union Ctypes.union Ctypes.typ

  type js_value = Bindings.Make(Quickjs__.Stubs).js_value

  val js_value : js_value Ctypes.structure Ctypes.typ

  val js_value_const : js_value Ctypes.structure Ctypes.typ

  type js_c_function_list_entry =
    Bindings.Make(Quickjs__.Stubs).js_c_function_list_entry

  val js_c_function_list_entry
    : js_c_function_list_entry Ctypes.structure Ctypes.typ

  val js_new_runtime
    : (unit ->
      js_runtime Ctypes.structure Ctypes_static.ptr Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_free_runtime
    : (js_runtime Ctypes.structure Ctypes_static.ptr ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_set_runtime_info
    : (js_runtime Ctypes.structure Ctypes_static.ptr ->
      string ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_set_memory_limit
    : (js_runtime Ctypes.structure Ctypes_static.ptr ->
      Unsigned.size_t ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_set_gc_threshold
    : (js_runtime Ctypes.structure Ctypes_static.ptr ->
      Unsigned.size_t ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_new_context
    : (js_runtime Ctypes.structure Ctypes_static.ptr ->
      js_context Ctypes.structure Ctypes_static.ptr Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_free_context
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_get_runtime
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_runtime Ctypes.structure Ctypes_static.ptr Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_set_max_stack_size
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      Unsigned.size_t ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_set_property_function_list
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      js_c_function_list_entry Ctypes.structure Ctypes_static.ptr ->
      int ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_free_value
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_free_value_rt
    : (js_runtime Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_dup_value
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_dup_value_rt
    : (js_runtime Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_uninitialized
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_error
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_exception
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_null
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_undefined
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_bool
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_number
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_string
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_symbol
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_array
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_object
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_function
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_constructor
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_instance_of
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_big_int
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_big_float
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_is_big_decimal
    : (js_value Ctypes.structure -> int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_to_bool
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_to_int32
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      int32 Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_to_uint32
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      Unsigned.uint32 Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_to_int64
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      int64 Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_to_float64
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      float Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_to_bigint64
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      int64 Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      int Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_to_string
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_to_c_string
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      string Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_free_c_string
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      string ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_get_exception
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_throw
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_set_class_proto
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      Unsigned.uint32 ->
      js_value Ctypes.structure ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_get_class_proto
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      Unsigned.uint32 ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_new_class_id
    : (Unsigned.uint32 Ctypes_static.ptr ->
      Unsigned.uint32 Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_new_object_proto_class
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      Unsigned.uint32 ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_new_object_class
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      int ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_new_object_proto
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_new_object
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_set_opaque
    : (js_value Ctypes.structure ->
      unit Ctypes_static.ptr ->
      unit Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_get_opaque
    : (js_value Ctypes.structure ->
      Unsigned.uint32 ->
      unit Ctypes_static.ptr Quickjs__.Stubs.return)
      Quickjs__.Stubs.result

  val js_eval
    : (js_context Ctypes.structure Ctypes_static.ptr ->
      string ->
      Unsigned.size_t ->
      string ->
      int ->
      js_value Ctypes.structure Quickjs__.Stubs.return)
      Quickjs__.Stubs.result
end

type runtime
(** JSRuntime represents a Javascript runtime corresponding to an object heap.
    Several runtimes can exist at the same time but they cannot exchange objects.
    Inside a given runtime, no multi-threading is supported.
    *)

type context
(** JSContext represents a Javascript context (or Realm). Each JSContext has
    its own global objects and system objects. There can be several JSContexts
    per JSRuntime and they can share objects, similar to frames of the same
    origin sharing Javascript objects in a web browser.
    *)

type value
(** JSValue represents a Javascript value which can be a primitive type or an object *)

module Value : sig
  val is_null : value -> bool

  val is_undefined : value -> bool

  val is_bool : value -> bool

  val is_number : value -> bool

  val is_string : value -> bool

  val is_symbol : value -> bool

  val is_array : value -> bool

  val is_object : value -> bool

  val is_function : value -> bool

  val is_constructor : value -> bool

  val is_exception : value -> bool

  val is_big_int : value -> bool

  val is_big_float : value -> bool

  val is_big_decimal : value -> bool

  val is_instance_of : value -> value -> bool

  val to_string : value -> (string, string) result

  val to_bool : value -> (bool, string) result

  val to_int32 : value -> (int32, string) result

  val to_uint32 : value -> (Unsigned.UInt32.t, string) result

  val to_int64 : value -> (int64, string) result

  val to_float : value -> (float, string) result

  val to_bigint64 : value -> (int64, string) result
end

val new_runtime : unit -> runtime

val new_context : runtime -> context

val eval : context -> string -> (value, string) result
(** [eval context script] *)

val eval_once : string -> (value, string) result
(** [eval_once script] *)

val get_exception : context -> string option

val get_exception_exn : context -> string
