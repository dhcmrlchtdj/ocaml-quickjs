let ( let* ) = Result.bind

let ( let+ ) r f = Result.map f r

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
  let _ = Quickjs.eval_unsafe ~ctx fib in
  let r = Quickjs.eval_unsafe ~ctx "fib(20)" in
  let+ r = Quickjs.Value.to_int32 r in
  print_endline (Int32.to_string r)

let _ =
  print_endline "\n###### test throw";
  let script = {| throw "some string" |} in
  let ex = Quickjs.eval script in
  match ex with
    | Ok _ -> assert false
    | Error e ->
      print_endline "exception catched";
      print_endline (Quickjs.Value.to_string e)

let _ =
  print_endline "\n###### test Value.is_xxx";
  let script = {| new Error("some error") |} in
  let+ err = Quickjs.eval script in
  if Quickjs.Value.is_error err then print_endline "is_error";
  print_endline (Quickjs.Value.to_string err)

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
  let* x = Quickjs.eval "0.1+0.2" in
  let* x = Quickjs.Value.to_float x in
  Printf.printf "%f\n" x;
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
  let+ r = Quickjs.Value.to_int32 r in
  print_endline (Int32.to_string r)

let _ =
  print_endline "\n###### test interrupt_handler";
  let ctx = Quickjs.new_runtime () |> Quickjs.new_context in
  let () =
    let rt = Quickjs.get_runtime_from_context ctx in
    let count = ref 0 in
    let cb _runtime =
      incr count;
      !count = 2
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
    | Error e -> print_endline (Quickjs.Value.to_string e)
