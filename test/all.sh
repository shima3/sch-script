#!/bin/bash
if [ $# == 0 ]
then
    echo Usage: "$0" 処理系 実行方式
    echo 実行方式: interpret または compile
    echo Example: "$0" gauche interpret
    exit 0
fi
for test in test/[0-9]*.sh
do
    /bin/bash test/$2.sh $1 $test
done
