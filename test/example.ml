module Q = Quickjs

let test () =
  let rt = Q.new_runtime () in
  let ctx = Q.new_context rt in
  let _ = Q.eval ctx "1+1" in
  ()
