let ( let* ) = Stdlib.Result.bind

let ok_unit = Ok ()

let _ =
  let* a = Quickjs.eval "[]" in
  let* a = Quickjs.Value.to_bool a in
  Printf.printf "%B\n" a;
  let* x = Quickjs.eval "10" in
  let* x = Quickjs.Value.to_int32 x in
  Printf.printf "%ld\n" x;
  let* x = Quickjs.eval "Number.MAX_SAFE_INTEGER" in
  let* x = Quickjs.Value.to_int64 x in
  Printf.printf "%Ld\n" x;
  let* x = Quickjs.eval "1n" in
  let* x = Quickjs.Value.to_int64 x in
  Printf.printf "%Ld\n" x;
  let* x = Quickjs.eval "0.1+0.2" in
  let* x = Quickjs.Value.to_float x in
  Printf.printf "%.17f\n" x;
  let* x = Quickjs.eval "233" in
  let* x = Quickjs.Value.to_uint32 x in
  Printf.printf "%s\n" (Unsigned.UInt32.to_string x);
  ok_unit
