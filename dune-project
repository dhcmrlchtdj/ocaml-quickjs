(lang dune 2.0)

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
  (ocaml                (and (>= 4.09.0)))
  (ctypes               (and (>= 0.16.0)))
  (ctypes-foreign       (and (>= 0.4.0)))
  (integers             (and (>= 0.3.0)))
  (ppx_deriving         (and :build (>= 4.4.1)))
  (dune                 (and :build (>= 2.3.0)))
  (dune-configurator    (and :build (>= 2.3.0)))
  (bisect_ppx           (and :build (>= 1.4.2)))
  (odoc                 (and :with-doc (>= 1.5.0)))
  (ocamlformat          (and :dev (>= 0.13.0)))
  ))

(generate_opam_files true)
