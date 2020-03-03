module Configurator = Configurator.V1
module C_define = Configurator.C_define

let () =
  let write_constants result =
    let out = open_out "constants.ml" in
    List.iter
      (fun (k, v) ->
        let write_ml = Printf.fprintf out "let const_%s = %s;;\n" in
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
          ~c_flags:
            [
              "-D_GNU_SOURCE";
              "-DCONFIG_VERSION=\"2020-01-19\"";
              "-DCONFIG_BIGNUM";
              include_quickjs;
            ]
          ~includes:[ "quickjs.h" ]
          [
            ("JS_NAN_BOXING", C_define.Type.Switch);
            (* ("CONFIG_BIGNUM", C_define.Type.Switch); *)
            (* JS_Eval() flags *)
            ("JS_EVAL_TYPE_GLOBAL", C_define.Type.Int);
            ("JS_EVAL_TYPE_MODULE", C_define.Type.Int);
            ("JS_EVAL_TYPE_DIRECT", C_define.Type.Int);
            ("JS_EVAL_TYPE_INDIRECT", C_define.Type.Int);
            ("JS_EVAL_TYPE_MASK", C_define.Type.Int);
            ("JS_EVAL_FLAG_STRICT", C_define.Type.Int);
            ("JS_EVAL_FLAG_STRIP", C_define.Type.Int);
            ("JS_EVAL_FLAG_COMPILE_ONLY", C_define.Type.Int);
            ("JS_EVAL_FLAG_BACKTRACE_BARRIER", C_define.Type.Int);
            (* struct JSCFunctionListEntry . def_type *)
            ("JS_DEF_CFUNC", C_define.Type.Int);
            ("JS_DEF_CGETSET", C_define.Type.Int);
            ("JS_DEF_CGETSET_MAGIC", C_define.Type.Int);
            ("JS_DEF_PROP_STRING", C_define.Type.Int);
            ("JS_DEF_PROP_INT32", C_define.Type.Int);
            ("JS_DEF_PROP_INT64", C_define.Type.Int);
            ("JS_DEF_PROP_DOUBLE", C_define.Type.Int);
            ("JS_DEF_PROP_UNDEFINED", C_define.Type.Int);
            ("JS_DEF_OBJECT", C_define.Type.Int);
            ("JS_DEF_ALIAS", C_define.Type.Int);
            (* enum JSCFunctionEnum *)
            ("JS_CFUNC_generic", C_define.Type.Int);
            ("JS_CFUNC_generic_magic", C_define.Type.Int);
            ("JS_CFUNC_constructor", C_define.Type.Int);
            ("JS_CFUNC_constructor_magic", C_define.Type.Int);
            ("JS_CFUNC_constructor_or_func", C_define.Type.Int);
            ("JS_CFUNC_constructor_or_func_magic", C_define.Type.Int);
            ("JS_CFUNC_f_f", C_define.Type.Int);
            ("JS_CFUNC_f_f_f", C_define.Type.Int);
            ("JS_CFUNC_getter", C_define.Type.Int);
            ("JS_CFUNC_setter", C_define.Type.Int);
            ("JS_CFUNC_getter_magic", C_define.Type.Int);
            ("JS_CFUNC_setter_magic", C_define.Type.Int);
            ("JS_CFUNC_iterator_next", C_define.Type.Int);
            (* flags for object properties *)
            ("JS_PROP_CONFIGURABLE", C_define.Type.Int);
            ("JS_PROP_WRITABLE", C_define.Type.Int);
            ("JS_PROP_ENUMERABLE", C_define.Type.Int);
            ("JS_PROP_C_W_E", C_define.Type.Int);
            ("JS_PROP_LENGTH", C_define.Type.Int);
            ("JS_PROP_TMASK", C_define.Type.Int);
            ("JS_PROP_NORMAL", C_define.Type.Int);
            ("JS_PROP_GETSET", C_define.Type.Int);
            ("JS_PROP_VARREF", C_define.Type.Int);
            ("JS_PROP_AUTOINIT", C_define.Type.Int);
            (* flags for JS_DefineProperty *)
            ("JS_PROP_HAS_SHIFT", C_define.Type.Int);
            ("JS_PROP_HAS_CONFIGURABLE", C_define.Type.Int);
            ("JS_PROP_HAS_WRITABLE", C_define.Type.Int);
            ("JS_PROP_HAS_ENUMERABLE", C_define.Type.Int);
            ("JS_PROP_HAS_GET", C_define.Type.Int);
            ("JS_PROP_HAS_SET", C_define.Type.Int);
            ("JS_PROP_HAS_VALUE", C_define.Type.Int);
            ("JS_PROP_THROW", C_define.Type.Int);
            ("JS_PROP_THROW_STRICT", C_define.Type.Int);
          ]
      in
      write_constants result)
