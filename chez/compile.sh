#!/bin/bash
file_ext=${1##*/}
base=${file_ext%.*}
chez --script chez/aid-compile.scm $1 chez/$base.so
chmod -x chez/$base.so
echo "chez/interpret.sh chez/$base.so \$*" > chez/$base
chmod +x chez/$base
