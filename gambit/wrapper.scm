(define (make-eqv-hashtable)(make-table test: eqv?))
(define (hash-table-ref/key table key)
  (table-ref table key key))
(define hash-table-set! table-set!)
(define (seconds->duration sec) sec)
(define (add-duration time duration)
  (seconds->time (+ (time->seconds time) duration)))
(define (time<? time1 time2)
  (< (time->seconds time1)(time->seconds time2)))
(define sleep thread-sleep!)
(define (fork-thread thunk)
  (thread-start! (make-thread thunk)))

(define (current-thread-specific)
  (thread-specific (current-thread))
  )
(define (current-thread-specific-set! value)
  (thread-specific-set! (current-thread) value)
  )

(define (string-concatenate list)
  (append-strings list))

(define (x->string x)
  (if (string? x) x
    (object->string x)))

(define (make-queue)
  (cons '( ) '( )))
(define (queue-empty? queue)
  (null? (car queue)))
(define (queue-first queue)
  (let ((first (car queue)))
    (if (null? first) '( )
      (car first))))
(define (queue-add! queue el)
  (let ((first (car queue))(last (cdr queue))(new-last (cons el '( ))))
    (if (null? first)
      (set-car! queue new-last)
      (set-cdr! last new-last))
    (set-cdr! queue new-last)
    (null? first) ; 削除予定
    )
  )
(define (queue-remove! queue)
  (let ((first (car queue)))
    (if (null? first)
      '( )
      (begin
	(set-car! queue (cdr first))
	(car first)))
    )
  )
