(lang dune 2.8)

(name quickjs)

(version 0.1.1)
(authors "H11 <nirisix@gmail.com>")
(maintainers "H11 <nirisix@gmail.com>")
(source
 (github dhcmrlchtdj/ocaml-quickjs))
(license MIT)

(package
 (name quickjs)
 (synopsis "OCaml bindings to QuickJS")
 (depends
  (ctypes               (and (>= 0.18.0)))
  (ctypes-foreign       (and (>= 0.18.0)))
  (integers             (and (>= 0.4.0)))
  (bisect_ppx           (and :build (>= 2.6.0)))
  (dune                 (and :build (>= 2.8.5)))
  (dune-configurator    (and :build (>= 2.8.5)))
  (ppx_deriving         (and :build (>= 5.2.1)))
  (odoc                 (and :with-doc (>= 1.5.2)))
  (ocamlformat          (and :dev (>= 0.18.0)))
  ))

(generate_opam_files true)
