#!/bin/bash
# if [ "$TEST_SCRIPT" == "" ]
# then
#     echo Test: $*
#    info=coverage/lcov.info
#else
#    echo $TEST_SCRIPT: $*
#    info=${TEST_SCRIPT%.*}.info
#fi
tmp=guile/lcov.info
rm -f $tmp
guile --debug -L $PWD -s guile/coverage.scm $tmp $*
