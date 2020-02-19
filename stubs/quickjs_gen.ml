let () =
  let _gen_c =
    let out = open_out "quickjs_stubs.c" in
    let fmt = Format.formatter_of_out_channel out in
    Format.fprintf fmt {|#include "quickjs.h"@.|};
    Cstubs.write_c fmt ~prefix:"caml_" (module Quickjs_bindings.Make);
    close_out out
  in
  let _gen_ml =
    let out = open_out "quickjs_stubs.ml" in
    let fmt = Format.formatter_of_out_channel out in
    Cstubs.write_ml fmt ~prefix:"caml_" (module Quickjs_bindings.Make);
    close_out out
  in
  flush_all ()
