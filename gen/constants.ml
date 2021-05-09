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
        | C_define.Value.String s -> write_ml k s
        )
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
          ~c_flags:
            [
              "-D_GNU_SOURCE";
              "-DCONFIG_VERSION=\"2021-03-27\"";
              "-DCONFIG_BIGNUM";
              include_quickjs;
            ]
          ~includes:[ "quickjs.h" ]
          [
            ("JS_NAN_BOXING", C_define.Type.Switch);
            (* ("CONFIG_BIGNUM", C_define.Type.Switch); *)
            ("JS_EVAL_TYPE_GLOBAL", C_define.Type.Int);
            ("JS_EVAL_TYPE_MODULE", C_define.Type.Int);
            ("JS_EVAL_TYPE_DIRECT", C_define.Type.Int);
            ("JS_EVAL_TYPE_INDIRECT", C_define.Type.Int);
            ("JS_EVAL_TYPE_MASK", C_define.Type.Int);
            ("JS_EVAL_FLAG_STRICT", C_define.Type.Int);
            ("JS_EVAL_FLAG_STRIP", C_define.Type.Int);
            ("JS_EVAL_FLAG_COMPILE_ONLY", C_define.Type.Int);
            ("JS_EVAL_FLAG_BACKTRACE_BARRIER", C_define.Type.Int);
          ]
      in
      write_constants result
  )
