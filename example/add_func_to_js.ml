let ( let* ) = Stdlib.Result.bind

let ok_unit = Ok ()

let _ =
  let fib ctx _this _args =
    let x = Quickjs.eval_unsafe ~ctx "1" in
    x
  in
  let ctx = Quickjs.new_runtime () |> Quickjs.new_context in
  let* f = Quickjs.add_func ctx fib "fib" 1 in
  print_endline (if Quickjs.Value.is_function f then "f is a function" else "");
  print_endline (Quickjs.Value.to_string f |> Option.get);
  let r = Quickjs.eval ~ctx "fib(20)" in
  match r with
    | Ok r ->
      let* r = Quickjs.Value.to_int32 r in
      print_endline (Int32.to_string r);
      ok_unit
    | Error e ->
      print_endline (Quickjs.Value.to_string e |> Option.get);
      ok_unit
