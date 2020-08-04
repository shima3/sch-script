#!/bin/bash
dir="${0%/*}"
export CHEZSCHEMELIBDIRS=/usr/local/Cellar/chezscheme/chez-srfi
chez --script ${dir}/aid-interpret.scm "${dir}/wrapper.scm" $*
# chez --script ${dir}/aid-interpret.scm -- $*
