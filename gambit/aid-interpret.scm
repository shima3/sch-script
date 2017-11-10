#!/usr/bin/env gsi-script
(include "wrapper.scm")
(let ((args (cdr (command-line))))
  (load (car args))
  ;; (display args)(newline)
  ;; (apply main-proc args)
  (with-exception-handler
    (lambda (ex)
      (println "variable=" (unbound-global-exception-variable ex))
      (exit 0)
      )
    (lambda ( )
      (apply main-proc args)
      ))
  )