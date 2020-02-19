let ( let* ) = Result.bind

let ( let+ ) r f = Result.map f r

let _ =
  let* sum = Quickjs.eval_once "1+1" in
  let typ = Quickjs.Value.is_string sum in
  print_endline (if typ then "sum is string" else "sum isn't string");
  let* sums = Quickjs.Value.to_string sum in
  print_endline sums;
  let typ = Quickjs.Value.is_number sum in
  print_endline (if typ then "sum is number" else "sum isn't number");
  let+ sumi = Quickjs.Value.to_int32 sum in
  sumi |> Int32.to_string |> print_endline

let _ =
  let script =
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
  let* r = Quickjs.eval_once script in
  let+ r = Quickjs.Value.to_string r in
  print_endline r
