#!/bin/bash
dir="${0%/*}"
export CHEZSCHEMELIBDIRS=/usr/local/Cellar/chezscheme/chez-srfi
file_ext="${1##*/}"
base="${file_ext%.*}"
scm="${dir}/tmp.scm"
dst="${dir}/${base}"
cat ${dir}/wrapper.scm $1 > ${scm}
chez --script ${dir}/aid-compile.scm ${scm} ${dst}.so
chmod -x ${dst}.so
echo "#!/bin/bash" > ${dst}
echo "chez --script \${0%/*}/aid-interpret.scm \$0.so \$*" >> ${dst}
chmod +x ${dst}
