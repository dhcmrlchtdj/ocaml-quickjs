let ( let* ) = Stdlib.Result.bind

let ok_unit = Ok ()

let _ =
  let open Quickjs.Value in
  let fib ctx _this args =
    let rec fib n =
      if n <= 0l
      then 0l
      else if n = 1l
      then 1l
      else Int32.(add (fib (sub n 1l)) (fib (sub n 2l)))
    in
    args
    |> List.hd
    |> To.int32
    |> Result.get_ok
    |> fib
    |> New.int32 ctx
    |> New.jsval ctx
  in
  let ctx = Quickjs.new_runtime () |> Quickjs.new_context in
  let* f = Quickjs.add_func ctx fib "fib" 1 in
  print_endline (if Is.js_function f then "f is a function" else "");
  print_endline (To.string f |> Option.get);
  let r = Quickjs.eval ~ctx "fib(20)" in
  match r with
    | Ok r ->
      let* r = To.int32 r in
      print_endline (Int32.to_string r);
      ok_unit
    | Error e ->
      print_endline (To.string e |> Option.get);
      ok_unit
