#!/bin/bash
src="${1##*/}"
prelude="(include \"$PWD/gambit/wrapper.scm\")"
gsc -exe -cc-options "-O3" -ld-options "-Wl,-no_compact_unwind" -prelude "$prelude" -postlude '(apply main-proc (command-line))' -o "gambit/${src%.*}" $*
