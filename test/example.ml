let ( let* ) = Result.bind

let ok_unit = Ok ()

let _ =
  print_endline "\n###### test eval";
  let fib =
    {|
    const fib = (n) => {
      if (n <= 1) {
        return n
      } else {
        return fib(n-2) + fib(n-1)
      }
    }
    |}
  in
  let ctx = Quickjs.new_runtime () |> Quickjs.new_context in
  let* _ = Quickjs.eval ~ctx fib in
  let* r = Quickjs.eval ~ctx "fib(20)" in
  let* r = Quickjs.Value.to_int32 r in
  print_endline (Int32.to_string r);
  ok_unit

let _ =
  print_endline "\n###### test throw";
  let script = {| throw "some string" |} in
  let ex = Quickjs.eval script in
  match ex with
    | Ok _ -> assert false
    | Error e ->
      print_endline "exception catched";
      print_endline (Quickjs.Value.to_string e |> Option.get)

let _ =
  print_endline "\n###### test Value.is_xxx";
  let open Quickjs.Value in
  let _ =
    let ctx = Quickjs.new_runtime () |> Quickjs.new_context in
    let d1 = Quickjs.eval_unsafe ~ctx "new Date()" in
    let d2 = Quickjs.eval_unsafe ~ctx "Date" in
    if is_instance_of d1 d2
    then print_endline "instanceof | pass"
    else print_endline "instanceof | fail"
  in
  let _ =
    let x = Quickjs.eval_unsafe "1" in
    let y = convert_to_string x in
    if is_number x && is_string y
    then print_endline "convert_to_string | pass"
    else print_endline "convert_to_string | fail"
  in
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
      (* (is_big_decimal, "1m"); *)
      (* (is_big_float, "1n"); *)
    ]
  in
  let iter_f (f, s) =
    let v = Quickjs.eval_unsafe s in
    let r = if f v then s ^ " | pass" else s ^ " | fail" in
    print_endline r
  in
  List.iter iter_f cases

let _ =
  print_endline "\n###### test Value.to_xxx";
  let* a = Quickjs.eval "[]" in
  let* a = Quickjs.Value.to_bool a in
  Printf.printf "%B\n" a;
  let* x = Quickjs.eval "10" in
  let* x = Quickjs.Value.to_int32 x in
  Printf.printf "%ld\n" x;
  let* x = Quickjs.eval "Number.MAX_SAFE_INTEGER" in
  let* x = Quickjs.Value.to_int64 x in
  Printf.printf "%Ld\n" x;
  let* x = Quickjs.eval "1n" in
  let* x = Quickjs.Value.to_int64 x in
  Printf.printf "%Ld\n" x;
  let* x = Quickjs.eval "0.1+0.2" in
  let* x = Quickjs.Value.to_float x in
  Printf.printf "%.17f\n" x;
  Ok ()

let _ =
  print_endline "\n###### test bytecode";
  let fib20 =
    {|
    const fib = (n) => {
      if (n <= 1) {
        return n
      } else {
        return fib(n-2) + fib(n-1)
      }
    }
    fib(20)
    |}
  in
  let* bc = Quickjs.compile fib20 in
  let* r = Quickjs.execute bc in
  let* r = Quickjs.Value.to_int32 r in
  print_endline (Int32.to_string r);
  ok_unit

let _ =
  print_endline "\n###### test interrupt_handler";
  let ctx = Quickjs.new_runtime () |> Quickjs.new_context in
  let () =
    let rt = Quickjs.get_runtime ctx in
    let count = ref 0 in
    let cb _runtime =
      incr count;
      print_endline "run once";
      !count < 1
    in
    Quickjs.set_interrupt_handler rt cb
  in
  let fib =
    {|
    const fib = (n) => {
      if (n <= 1) {
        return n
      } else {
        return fib(n-2) + fib(n-1)
      }
    }
    fib(20)
    |}
  in
  let r = Quickjs.eval ~ctx fib in
  match r with
    | Ok _ -> assert false
    | Error e -> print_endline (Quickjs.Value.to_string e |> Option.get)
