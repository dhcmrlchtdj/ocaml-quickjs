(lang dune 2.0)

(name quickjs)

(version 0.1.0)
(authors "H11 <nirisix@gmail.com>")
(maintainers "H11 <nirisix@gmail.com>")
(source
 (github dhcmrlchtdj/ocaml-quickjs))
(license MIT)

(package
 (name quickjs)
 (synopsis "OCaml bindings to quickjs")
 (depends
  (ocaml                (and (>= 4.09.0)))
  (ctypes               (and (>= 0.16.0)))
  (ctypes-foreign       (and (>= 0.4.0)))
  (dune                 (and :build (>= 2.3.0)))
  (ocamlformat          (and :dev (>= 0.13.0)))
  ))

(generate_opam_files true)
