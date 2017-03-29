#!/bin/bash
gsc -exe -cc-options "-O3" -ld-options "-Wl,-no_compact_unwind" -prelude '(include "gambit/prologue.scm")' -postlude '(apply main-proc (command-line))' -o gambit/${1%.*} $*
