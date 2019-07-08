(require-extension r7rs)
(require-library ir-macros)
(import ir-macros)

(define (seconds->duration sec) sec)
(define (fork-thread thunk)
  (thread-start! (make-thread thunk)))
(define (sleep duration)
  (thread-sleep! (add-duration (current-time) duration))
  duration)
(define (add-duration time duration)
  (seconds->time (+ (time->seconds time) duration)))
(define (time<? time1 time2)
  (< (time->seconds time1)(time->seconds time2)))
(define (test . args)
  (display "args=")
  (display args)
  (newline)
  )
;; (apply main-proc (cons (program-name)(command-line-arguments)))

(define (current-thread-specific)
  (thread-specific (current-thread))
  )
(define (current-thread-specific-set! value)
  (thread-specific-set! (current-thread) value)
  )
(define (make-eqv-hashtable)
  (make-hash-table eqv? eqv?-hash))
(define (hash-table-ref/key table key)
  (hash-table-ref/default table key key))

#; (define (x->string x)
  (if (string? x) x
    (object->string x)))

(define (x->string x)
  (cond
    ((string? x) x)
    ((symbol? x)(symbol->string x))
    ((number? x)(number->string x))
    ((null? x) "()")
    ((pair? x)(string-append "(" (concatenate-with-space x) ")"))
    ((boolean? x)(if x "#t" "#f"))
    (else "???")))

#; (define (x->string x)
  (display x)(newline)
  (if (list? x)(string-append "(" (concatenate-with-space x) ")")
    (call-with-output-string (lambda (p)(display x p)))))

(define (concatenate-with-space list)
  (let ( (first (x->string (car list)))
	 (rest (cdr list)) )
    (cond
      ((null? rest) first)
      ((pair? rest)
	(string-append first " "
	  (concatenate-with-space rest)))
      (else (string-append first " . " (x->string rest)))
      )))

#; (define-macro (define-type Name . Fields)
  (cons 'define-record-type
    (cons Name
      (cons
	(cons (string->symbol (string-append "make-" (symbol->string Name)))
	  Fields)
	(cons (string->symbol (string-append (symbol->string Name) "?"))
	  (map (lambda (field)
		 (list field
		   (string->symbol
		     (string-append (symbol->string Name) "-"
		       (symbol->string field)))
		   (string->symbol
		     (string-append (symbol->string Name) "-"
		       (symbol->string field) "-set!")))) Fields)))))
  )

#; (define (make-queue)
  (cons '( ) '( )))
#; (define (queue-empty? queue)
  (null? (car queue)))
#; (define (queue-peek queue)
  (let ((first (car queue)))
    (if (null? first) '( )
      (car first))))
#; (define (queue-add! queue el)
  (let ((first (car queue))(last (cdr queue))(new-last (cons el '( ))))
    (if (null? first)
      (set-car! queue new-last)
      (set-cdr! last new-last))
    (set-cdr! queue new-last)
    (null? first) ; 削除予定
    )
  )
#; (define (queue-remove! queue)
  (let ((first (car queue)))
    (if (null? first)
      '( )
      (begin
	(set-car! queue (cdr first))
	(car first)))
    )
  )

(define-syntax define-type
  (ir-macro-transformer
    (lambda (src inject compare)
      (let ( (Name (inject (cadr src))) (Fields (inject (cddr src))) )
	(let 
	  ( (Constructor
	      (cons (string->symbol
		      (string-append "make-" (symbol->string Name))) Fields))
	    (Predicate
	      (string->symbol (string-append (symbol->string Name) "?")))
	    (FieldSpecs
	      (map (lambda (field)
		     (list field
		       (string->symbol
			 (string-append (symbol->string Name) "-"
			   (symbol->string field)))
		       (string->symbol
			 (string-append (symbol->string Name) "-"
			   (symbol->string field) "-set!")))) Fields))
	    )
	  (let
	    ( (dst
		`(define-record-type ,Name ,Constructor ,Predicate
		   ,@FieldSpecs))
	      )
	    ;; (println dst)
	    dst
	    )
	  )
	)
      ))
  )
