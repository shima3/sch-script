#!/usr/bin/env gosh
(use srfi-69)
(add-load-path ".")
(load (car (cdr (command-line))))
(apply main-proc (cdr (command-line)))
