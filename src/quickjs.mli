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

end

val new_runtime : unit -> runtime

val new_context : runtime -> context

val eval : context -> string -> (value, string) result
(** [eval context script] *)

val eval_once : string -> (value, string) result
(** [eval_once script] *)

val get_exception : context -> string option

val get_exception_exn : context -> string
