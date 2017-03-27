#!/bin/bash
for test in test/[0-9]*.sh
do
    /bin/bash $test $1
done
