(*
https://dune.build/blog/configurator-constants/
https://github.com/ocaml/dune/blob/2.3.0/otherlibs/configurator/test/blackbox-tests/test-cases/configurator/import-define/run.ml
*)

module Configurator = Configurator.V1
module C_define = Configurator.C_define

let () =
  let write_constants result =
    let out = open_out "constants.ml" in
    List.iter
      (fun (k, v) ->
        let write_ml = Printf.fprintf out "let define_%s = %s;;\n" in
        match v with
          | C_define.Value.Switch b -> write_ml k (string_of_bool b)
          | C_define.Value.Int n -> write_ml k (string_of_int n)
          | C_define.Value.String s -> write_ml k s)
      result;
    flush out;
    close_out out
  in
  let include_quickjs =
    (* TODO: is there any better way to get relative dir? *)
    let working_dir = Sys.getcwd () in
    "-I" ^ working_dir ^ "/../vendor/quickjs"
  in
  Configurator.main ~name:"import_constants" (fun t ->
      let result =
        C_define.import
          t
          ~c_flags:[ include_quickjs ]
          ~includes:[ "quickjs.h" ]
          [ ("JS_NAN_BOXING", C_define.Type.Switch) ]
      in
      write_constants result)
