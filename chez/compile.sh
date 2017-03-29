#!/bin/bash
base=${1%.*}
chez --script chez/aid-compile.scm $1 chez/$base.so
chmod -x chez/$base.so
echo "chez/run.sh chez/$base.so \$*" > chez/$base
chmod +x chez/$base
