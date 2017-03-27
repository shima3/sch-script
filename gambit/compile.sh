gsc -exe -cc-options "-O5" -prelude "(define (command-line-arguments)(cdr (command-line)))" -o gambit/${1%.*} $*
