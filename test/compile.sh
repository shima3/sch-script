#!/bin/bash
if [ $# == 0 ]
then
    echo Usage: "$0" 処理系 テストケース
    echo Example: "$0" chicken test/2.sh
    echo Internal Usage: "$0" 処理系 - スクリプト 引数・・・
    exit 0
fi
self="$0"
scheme="$1"
test="$2"
if [ "$test" == "-" ]
then
    source="${3##*/}"
    executable="$scheme/${source%.*}"
    if [ ! "$executable" -nt "$3" ]
    then
	"$scheme/compile.sh" "$3"
    fi
    shift 3
    "$executable" $*
else
    /bin/bash "$test" "$self" "$scheme" -
fi
