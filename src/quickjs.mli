type runtime
(** [runtime] represents a Javascript runtime corresponding to an object heap.
    Several runtimes can exist at the same time but they cannot exchange
    objects. Inside a given runtime, no multi-threading is supported.
    *)

type context
(** [context] represents a Javascript context (or Realm). Each context has
    its own global objects and system objects. There can be several contexts
    per runtime and they can share objects, similar to frames of the same
    origin sharing Javascript objects in a web browser.
    *)

type value
(** [value] represents a Javascript value which can be a primitive type or an
    object.
    *)

type js_exn = value

type 'a or_js_exn = ('a, js_exn) result

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

  val is_error : value -> bool

  val is_exception : value -> bool

  val is_big_int : value -> bool

  val is_big_float : value -> bool

  val is_big_decimal : value -> bool

  val is_instance_of : value -> value -> bool

  val to_string : value -> string

  val to_bool : value -> bool or_js_exn

  val to_int32 : value -> int32 or_js_exn

  val to_uint32 : value -> Unsigned.UInt32.t or_js_exn

  val to_int64 : value -> int64 or_js_exn

  val to_float : value -> float or_js_exn
end

val new_runtime : unit -> runtime

val new_context : runtime -> context

val eval_once : string -> value or_js_exn
(** [eval_once script] *)

val eval : context -> string -> value or_js_exn
(** [eval context script] *)

val eval_unsafe : context -> string -> value
(** [eval_unsafe context script], you must check exception by yourself *)

val get_exception : context -> value
