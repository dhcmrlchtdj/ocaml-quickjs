(lang dune 2.7)

(allow_approximate_merlin)

(name quickjs)

(version 0.1.0)
(authors "H11 <nirisix@gmail.com>")
(maintainers "H11 <nirisix@gmail.com>")
(source
 (github dhcmrlchtdj/ocaml-quickjs))
(license MIT)

(package
 (name quickjs)
 (synopsis "OCaml bindings to QuickJS")
 (depends
  (ocaml                (and (>= 4.10.0)))
  (ctypes               (and (>= 0.17.1)))
  (ctypes-foreign       (and (>= 0.4.0)))
  (integers             (and (>= 0.4.0)))
  (ppx_deriving         (and :build (>= 4.5)))
  (dune                 (and :build (>= 2.7.1)))
  (dune-configurator    (and :build (>= 2.7.1)))
  (bisect_ppx           (and :build (>= 2.4.1)))
  (odoc                 (and :with-doc (>= 1.5.1)))
  (ocamlformat          (and :dev (>= 0.15.0)))
  ))

(generate_opam_files true)
