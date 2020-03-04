let ( let* ) = Stdlib.Result.bind

let ok_unit = Ok ()

let _ =
  let fib ctx _this argc argv =
    Printf.printf "argc = %d\n" argc;
    let int_ptr = Ctypes.(allocate int32_t 0l) in
    let arg1 = Ctypes.( !@ ) argv in
    let _n = Quickjs_raw.js_to_int32 ctx int_ptr arg1 in
    Quickjs_raw.js_new_int32 ctx 0l
  in
  let rt = Quickjs_raw.js_new_runtime () in
  let ctx = Quickjs_raw.js_new_context rt in
  let global = Quickjs_raw.js_get_global_object ctx in
  let entry = Quickjs_raw.JS_C_function.js_cfunc_def "fib" 1 fib in
  let entries =
    Ctypes.allocate_n Quickjs_raw.JS_C_function.list_entry ~count:1
  in
  let () = Ctypes.(entries <-@ entry) in
  Quickjs_raw.js_set_property_function_list ctx global entries 1;
  let jsval =
    Quickjs_raw.js_eval ctx "fib()" (Unsigned.Size_t.of_int 6) "input.js" 0
  in
  let cstring = Quickjs_raw.js_to_c_string ctx jsval in
  let ch = Ctypes.(!@cstring) in
  print_char ch;
  ok_unit
