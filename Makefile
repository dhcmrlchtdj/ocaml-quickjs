SHELL := bash

build:
	dune build @install --profile=dev

test:
	dune runtest

test_update:
	dune runtest --auto-promote

clean:
	dune clean

fmt:
	dune build @fmt --auto-promote

doc:
	dune build @doc

release:
	dune build @install --profile=release

install: release
	opam install .

uninstall: release
	opam remove .

.PHONY: build test clean fmt doc release install uninstall test_update
