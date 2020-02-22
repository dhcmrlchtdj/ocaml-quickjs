(** QuickJS *)

(** {1 type} *)

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

type bytecode
(** [bytecode] represents the bytecode which is generated by {! compile} and
    can be executed with {! execute}.
    *)

type js_exn = value
(** JS can throw any [value] *)

type 'a or_js_exn = ('a, js_exn) result

(** {1 runtime} *)

val new_runtime : unit -> runtime

val set_memory_limit : runtime -> Unsigned.size_t -> unit

val set_gc_threshold : runtime -> Unsigned.size_t -> unit

type interrupt_handler = runtime -> bool
(** [interrupt_handler runtime] return false will interrupt runtime *)

val set_interrupt_handler : runtime -> interrupt_handler -> unit

(** {1 context} *)

val new_context : runtime -> context

val get_runtime_from_context : context -> runtime

val set_max_stack_size : context -> Unsigned.size_t -> unit

(** {1 value} *)

(** convert [value] to ocaml data *)
module Value : sig
  val convert_to_string : value -> value

  val is_uninitialized : value -> bool

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

  val to_uint32 : value -> Unsigned.uint32 or_js_exn

  val to_int64 : value -> int64 or_js_exn

  val to_float : value -> float or_js_exn
end

val check_exception : value -> value or_js_exn
(** [check_exception value] get exception obj from context.
    {b Cannot be called twice with the same [value]}.
{[
let _ =
  let open Quickjs in
  let r = eval_unsafe script in
  match check_exception r with
  | Ok obj -> "it is safe to use " ^ (Value.to_string obj)
  | Error js_exn -> "eval_unsafe throw " ^ (Value.to_string js_exn)
]}
*)

(** {1 eval} *)

type eval_type =
  [ `GLOBAL  (** global code (default) *)
  | `MODULE  (** module code *)
  ]

type eval_flag =
  [ `STRICT  (** force 'strict' mode *)
  | `STRIP  (** force 'strip' mode *)
  | `BACKTRACE_BARRIER
    (** don't include the stack frames before this eval in the Error() backtraces *)
  ]

val eval
  :  ?typ:eval_type ->
  ?flags:eval_flag list ->
  ?ctx:context ->
  string ->
  value or_js_exn
(** [eval ~typ ~flags ~ctx script] *)

val eval_unsafe
  :  ?typ:eval_type ->
  ?flags:eval_flag list ->
  ?ctx:context ->
  string ->
  js_exn
(** [eval_unsafe ~typ ~flags ~ctx script], you must check exception by yourself. {!val:check_exception} *)

val compile
  :  ?typ:eval_type ->
  ?flags:eval_flag list ->
  ?ctx:context ->
  string ->
  bytecode or_js_exn
(** [compile ~typ ~flags ~ctx script] *)

val execute : bytecode -> value or_js_exn
(** [execute bytecode] *)

(** {1 raw} *)

(** convert [Quickjs.xxx] to [Quickjs_raw.xxx] *)
module Raw : sig
  val of_runtime : runtime -> Quickjs_raw.js_runtime_ptr
  (** [of_runtime runtime] get raw represent of [runtime] *)

  val of_context : context -> Quickjs_raw.js_context_ptr
  (** [of_context context] get raw represent of [context] *)

  val of_value : value -> Quickjs_raw.js_value
  (** [of_value value] get raw represent of [value] *)

  val of_bytecode : bytecode -> Quickjs_raw.js_value
  (** [of_bytecode bytecode] get raw represent of [bytecode] *)
end