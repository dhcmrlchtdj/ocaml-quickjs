let ( let* ) = Result.bind

let test () =
  let* sum = Quickjs.eval_once "1+1" in
  let typ = Quickjs.Value.is_string sum in
  print_endline (if typ then "sum is string" else "sum isn't string");
  let* sums = Quickjs.Value.to_string sum in
  print_endline sums;
  let typ = Quickjs.Value.is_number sum in
  print_endline (if typ then "sum is number" else "sum isn't number");
  let* sumi = Quickjs.Value.to_int32 sum in
  Ok (sumi |> Int32.to_string |> print_endline)

let _ = test ()
