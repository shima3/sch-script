
(define-macro (define-record Name . Fields)
  (cons 'define-record-type
    (cons Name
      (cons
	(cons (string->symbol (string-append "make-" (symbol->string Name)))
	  Fields)
	(cons (string->symbol (string-append (symbol->string Name) "?"))
	  (map list Fields)))))
  )
