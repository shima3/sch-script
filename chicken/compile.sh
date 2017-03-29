csc -O5 -R srfi-69 -postlude '(apply main-proc (cons (program-name)(command-line-arguments)))' -o chicken/${1%.*} $*
