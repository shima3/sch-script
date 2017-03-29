#!/bin/bash
tmp=guile/lcov.info
rm -f $tmp
guile --debug -L $PWD -s guile/aid-coverage.scm $tmp $*
