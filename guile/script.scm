(define (command-line-arguments)(cdr (cdr (command-line))))
;; (define (cons-alist key datum alist)(cons (cons key datum) alist))
;; (define (eval1 expr)(eval expr (interaction-environment)))
;; (include "schscript.scm")
;; (add-to-load-path ".")
(include "common.scm")
(load-from-path (car (cdr (command-line))))
