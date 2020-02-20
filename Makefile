SHELL := bash

build:
	dune build @install --profile=dev

test:
	dune runtest

clean:
	dune clean

fmt:
	ocamlformat -i */*.ml{,i}

doc:
	dune build @doc

release:
	dune build @install --profile=release

install: release
	opam install .

uninstall: release
	opam remove .

.PHONY: build test clean fmt doc release install uninstall
