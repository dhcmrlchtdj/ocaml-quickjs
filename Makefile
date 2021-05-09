SHELL := bash

.PHONY: build release test test_update coverage clean fmt doc dep install uninstall upgrade_quickjs

build:
	opam exec dune -- build @install --profile=dev

release:
	opam exec dune -- build @install --profile=release

test:
	OCAMLRUNPARAM=b opam exec dune -- runtest

test_update:
	-opam exec dune -- runtest --auto-promote

coverage:
	opam exec dune -- clean
	OCAMLRUNPARAM=b opam exec dune -- runtest --instrument-with bisect_ppx
	opam exec bisect-ppx-report -- coveralls _coverage/coverage.json
	opam exec bisect-ppx-report -- html
	opam exec bisect-ppx-report -- summary

clean:
	opam exec dune -- clean
	rm -rf ./_coverage

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
		-e "s/-DCONFIG_VERSION=\\\\\"[-0-9]+\\\\\"/-DCONFIG_VERSION=\\\\\"$(shell cat vendor/quickjs/VERSION)\\\\\"/" \
		vendor/dune gen/constants.ml
	rm vendor/dune.bak
	rm gen/constants.ml.bak
