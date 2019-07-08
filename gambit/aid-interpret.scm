#!/usr/bin/env gsi-script
(include "wrapper.scm")
(let ((args (cdr (command-line))))
  (load (car args))
  ;; (display args)(newline)
  ;; (apply main-proc args)
  (with-exception-handler
    (lambda (ex)
      (cond
	((unbound-global-exception? ex)
	  (println "Error: unbound variable: "
	    (unbound-global-exception-variable ex)))
	((type-exception? ex)
	  (println "Error: incorrect type of arguments for "
	    (type-exception-procedure ex))
	  (println "Expected: " (type-exception-type-id ex)))
	(else (println ex)))
      (exit 0)
      )
    (lambda ( )
      (apply main-proc args)
      ))
  )
