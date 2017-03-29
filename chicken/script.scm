(include "chicken/prologue.scm")
(define cmdargs (command-line-arguments))
(define (command-line-arguments)(cdr cmdargs))
(load (car cmdargs))
