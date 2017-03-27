#!/usr/bin/env gsi
;; (load "~~lib/syntax-case")
;; (define (program-name)(car (command-line)))
;; (define command-line-arguments-sexp '(cdr (command-line)))
;; (define (cons-alist key datum alist)(cons (cons key datum) alist))
;; (define (eval1 expr)(eval expr (interaction-environment)))
(define (command-line-arguments)(cdr (cdr (command-line))))
(load (car (cdr (command-line))))
