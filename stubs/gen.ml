let c_headers = {|#include "quickjs.h"|}

let () =
  let _gen_c =
    let out = open_out "stubs.c" in
    let fmt = Format.formatter_of_out_channel out in
    Format.fprintf fmt "%s\n" c_headers;
    Cstubs.write_c fmt ~prefix:"caml_" (module Bindings.Make);
    close_out out
  in
  let _gen_ml =
    let out = open_out "stubs.ml" in
    let fmt = Format.formatter_of_out_channel out in
    Cstubs.write_ml fmt ~prefix:"caml_" (module Bindings.Make);
    close_out out
  in
  flush_all ()
