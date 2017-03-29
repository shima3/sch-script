(use-modules
 (system vm coverage)
 (system vm vm))
(define org-exit exit)
(define exit-code 0)
(include "prologue.scm")
(let ((args (cdr (command-line))))
  (let ((args2 (cdr args)))
    (load-from-path (car args2))
    (call-with-values
      (lambda ( )
	(with-code-coverage
	  (lambda ( )
	    (call/cc
	      (lambda (cont)
		(set! exit
		  (lambda (code)
		    (set! exit org-exit)
		    (cont code)))
		(apply main-proc args2)
		)))))
      (lambda (data result)
	(let ((port (open-output-file (car args))))
	  (coverage-data->lcov data port)
	  (close port)
	  )))
    ))
