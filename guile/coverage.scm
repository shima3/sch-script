(use-modules
 (system vm coverage)
 (system vm vm))
;; (display (command-line))(newline)
(define cmdargs (cdr (command-line)))
;; (display cmdargs)(newline)
;; (display (car (cdr cmdargs)))(newline)
(define (command-line-arguments)(cdr (cdr cmdargs)))
;; (display (command-line-arguments))(newline)
;; (exit 0)
(define org-exit exit)
(define exit-code 0)
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
	    (load-from-path (car (cdr cmdargs)))
	    )))))
  (lambda (data result)
    (let ((port (open-output-file (car cmdargs))))
      (coverage-data->lcov data port)
      (close port)
      )))
