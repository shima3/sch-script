#!/bin/bash
base=${1%.*}
chez --script chez/compile.scm $1 chez/$base.so
chmod -x chez/$base.so
echo "chez --script chez/$base.so \$*" > chez/$base.sh
chmod +x chez/$base.sh
