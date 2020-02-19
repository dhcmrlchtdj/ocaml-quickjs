let test () =
  let rt = Quickjs.new_runtime () in
  let ctx = Quickjs.new_context rt in
  let _ = Quickjs.eval ctx "1+1" in
  ()
