let ( let* ) = Stdlib.Result.bind

let ok_unit = Ok ()

let _ =
  let open Quickjs.Value in
  let _ =
    let ctx = Quickjs.new_runtime () |> Quickjs.new_context in
    let* d1 = Quickjs.eval ~ctx "new Date()" in
    let* d2 = Quickjs.eval ~ctx "Date" in
    if Is.instance_of d1 d2
    then print_endline "instanceof | pass"
    else print_endline "instanceof | fail";
    ok_unit
  in
  let _ =
    let* x = Quickjs.eval "1" in
    let y = To.string_value x in
    if Is.number x && Is.string y
    then print_endline "convert_to_string | pass"
    else print_endline "convert_to_string | fail";
    ok_unit
  in
  let _ =
    let cases =
      [
        (Is.null, "null");
        (Is.undefined, "undefined");
        (Is.bool, "true");
        (Is.number, "1");
        (Is.string, {|"string"|});
        (Is.symbol, "Symbol()");
        (Is.array, "[]");
        (Is.js_object, "({obj:true})");
        (Is.js_function, "parseInt");
        (Is.constructor, "String");
        (Is.error, "new Error()");
        (Is.big_int, "1n");
        (Is.big_decimal, "1m");
        (Is.big_float, "1l");
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
