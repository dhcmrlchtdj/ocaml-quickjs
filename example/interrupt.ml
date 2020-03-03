let ( let* ) = Stdlib.Result.bind

let ok_unit = Ok ()

let _ =
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
    | Error e -> print_endline (Quickjs.Value.To.string e |> Option.get)
