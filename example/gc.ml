let _ =
  let rt = Quickjs.new_runtime () in
  let () = Quickjs.run_gc rt in
  (* let stats = Quickjs.(compute_memory_usage rt |> memory_usage_to_string) in *)
  (* print_endline stats *)
  ()
