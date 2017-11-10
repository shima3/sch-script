#!/bin/bash
if [ $# == 0 ]
then
    echo Usage: "$0" 処理系 テストケース
    echo Example: "$0" chez test/1.sh
    exit 0
fi
scheme="$1"
test="$2"
/bin/bash "$test" "$scheme/interpret.sh"
