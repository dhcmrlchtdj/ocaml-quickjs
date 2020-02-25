let ( let* ) = Stdlib.Result.bind

let ok_unit = Ok ()

let _ =
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
