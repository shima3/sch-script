(define make-hash-table make-eqv-hashtable)
(define (hash-table-ref/key table key)
    (hashtable-ref table key key))
(define hash-table-set! hashtable-set!)

(define make-condition-variable make-condition)
(define (seconds->duration sec)
  (if (flonum? sec)
    (let ((s (floor sec)))
      (let ((ns (- sec s)))
	(set! s (flonum->fixnum s))
	(set! ns (flonum->fixnum (* ns 1000000000)))
	(make-time 'time-duration ns s)
	)
      )
    (make-time 'time-duration 0 sec))
  )
(define mutex-lock! mutex-acquire)
(define mutex-unlock! mutex-release)
(define condition-variable-signal! condition-signal)

(define thread-specific-table (make-hash-table))
(define thread-specific-mutex (make-mutex))
(define (current-thread-specific)
  (let ((value '( )))
    (mutex-lock! thread-specific-mutex)
    (set! value (hashtable-ref thread-specific-table (get-thread-id) '( )))
    (mutex-unlock! thread-specific-mutex)
    value)
  ;; (hash-table-ref/default thread-specific-table (get-thread-id) '( ))
  )
(define (current-thread-specific-set! value)
  (mutex-lock! thread-specific-mutex)
  (hash-table-set! thread-specific-table (get-thread-id) value)
  (mutex-unlock! thread-specific-mutex)
  )
