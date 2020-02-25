let ( let* ) = Stdlib.Result.bind

let ok_unit = Ok ()

let _ =
  let open Quickjs.Value in
  let _ =
    let ctx = Quickjs.new_runtime () |> Quickjs.new_context in
    let* d1 = Quickjs.eval ~ctx "new Date()" in
    let* d2 = Quickjs.eval ~ctx "Date" in
    if is_instance_of d1 d2
    then print_endline "instanceof | pass"
    else print_endline "instanceof | fail";
    ok_unit
  in
  let _ =
    let* x = Quickjs.eval "1" in
    let y = convert_to_string x in
    if is_number x && is_string y
    then print_endline "convert_to_string | pass"
    else print_endline "convert_to_string | fail";
    ok_unit
  in
  let _ =
    let cases =
      [
        (is_null, "null");
        (is_undefined, "undefined");
        (is_bool, "true");
        (is_number, "1");
        (is_string, {|"string"|});
        (is_symbol, "Symbol()");
        (is_array, "[]");
        (is_object, "({obj:true})");
        (is_function, "parseInt");
        (is_constructor, "String");
        (is_error, "new Error()");
        (is_big_int, "1n");
        (is_big_decimal, "1m");
        (is_big_float, "1l");
      ]
    in
    let iter_f (f, s) =
      let v = Quickjs.eval_unsafe s in
      let r = if f v then s ^ " | pass" else s ^ " | fail" in
      print_endline r
    in
    List.iter iter_f cases
  in
  ()
