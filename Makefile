SHELL := bash

build:
	opam exec dune -- build @install --profile=dev

release:
	opam exec dune -- build @install --profile=release

test:
	OCAMLRUNPARAM=b opam exec dune -- runtest --instrument-with bisect_ppx

test_update:
	-opam exec dune -- runtest --auto-promote --instrument-with bisect_ppx

coverage:
	opam exec dune -- clean
	OCAMLRUNPARAM=b opam exec dune -- runtest --instrument-with bisect_ppx
	opam exec bisect-ppx-report -- coveralls _coverage/coverage.json
	opam exec bisect-ppx-report -- html
	opam exec bisect-ppx-report -- summary

clean:
	opam exec dune -- clean

fmt:
	-opam exec dune -- build @fmt --auto-promote

doc:
	opam exec dune -- build @doc

dep:
	opam depext -yt conf-pkg-config
	opam install . --deps-only --with-test

install: release
	opam install .

uninstall: release
	opam remove .

upgrade_quickjs:
	cd ./vendor/quickjs && git pull
	sed -i.bak -E \
		-e "s/-DCONFIG_VERSION=\\\\\"[^\"]+\\\\\"/-DCONFIG_VERSION=\\\\\"`cat vendor/quickjs/VERSION`\\\\\"/" \
		vendor/dune gen/constants.ml
	rm vendor/dune.bak
	rm gen/constants.ml.bak

.PHONY: build test clean fmt doc release install uninstall test_update coverage dep
