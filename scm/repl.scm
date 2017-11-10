(define (test2)(display "Test 2")(newline))
(define (main-proc cmd . args)
  (let loop ((exp (read)))
    ;; (if (not (equal? exp #!eof))
    (if (not (eof-object? exp))
      (begin
	(display (eval exp (interaction-environment)))
	(newline)
	(loop (read))
	))
    )
  )
