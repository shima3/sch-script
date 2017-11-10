(use gauche.threads)
(use util.queue)
(use srfi-13)
(use srfi-19)
(use srfi-69)
(define (seconds->duration sec)
  (receive (ns s)(modf sec)
    (set! ns (x->integer (* ns 1000000000)))
    (set! s (x->integer s))
    (make-time 'time-duration ns s)))
(define (fork-thread thunk)
  (thread-start! (make-thread thunk)))
(define sleep thread-sleep!)
(define (current-thread-specific)
  (thread-specific (current-thread))
  )
(define (current-thread-specific-set! value)
  (thread-specific-set! (current-thread) value)
  )
(define (make-eqv-hashtable)
  (make-hash-table eqv?))
(define (hash-table-ref/key table key)
  ;; (hash-table-get table key key)
  (hash-table-ref/default table key key)
  #; (guard (e (else key))
  (hash-table-ref/default table key key))
  )
(add-load-path ".")
(load (car (cdr (command-line))))
(apply main-proc (cdr (command-line)))