let ( let* ) = Stdlib.Result.bind

let ok_unit = Ok ()

let _ =
  let script = {| throw "some string" |} in
  let ex = Quickjs.eval script in
  match ex with
    | Ok _ -> assert false
    | Error e ->
      print_endline "exception catched";
      print_endline (Quickjs.Value.to_string e |> Option.get)
