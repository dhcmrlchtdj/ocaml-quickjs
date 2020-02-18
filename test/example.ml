open Quickjs.C

let test () =
  let rt = js_new_runtime () in
  let ctx = js_new_context rt in
  let s = Unsigned.Size_t.of_int 3 in
  let _r = js_eval ctx "1+1" s "a.js" 0 in
  ()
