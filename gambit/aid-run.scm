#!/usr/bin/env gsi-script
(include "prologue.scm")
(let ((args (cdr (command-line))))
  (load (car args))
  (apply main-proc args))
