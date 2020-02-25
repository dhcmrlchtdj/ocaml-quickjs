let ( let* ) = Stdlib.Result.bind

let ok_unit = Ok ()

let _ =
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
  let* bc = Quickjs.compile ~flags:[ `STRIP; `STRICT ] fib20 in
  let* r = Quickjs.execute bc in
  let* r = Quickjs.Value.to_int32 r in
  print_endline (Int32.to_string r);
  ok_unit
