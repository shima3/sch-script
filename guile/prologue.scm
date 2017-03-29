(import (rnrs (6)))
(define make-hash-table make-eqv-hashtable)
(define hash-table-ref/default hashtable-ref)
(define hash-table-set! hashtable-set!)
