(define-cps cps-print ^(value)
  (lambda (value)(display value)(newline)) value)

(define-cps cps-< ^(left right) left ^(left) right ^(right)
  (lambda (left right)(< left right)) left right)

(define-cps cps-= ^(left right) left ^(left) right ^(right)
  (lambda (left right)(= left right)) left right)

(define-cps cps-+ ^(left right) left ^(left) right ^(right)
  (lambda (left right)(+ left right)) left right)

(define-cps cps-* ^(left right) left ^(left) right ^(right)
  (lambda (left right)(* left right)) left right)

(define-cps cps-remainder ^(left right) left ^(left) right ^(right)
  (lambda (left right)(remainder left right)) left right)

(define-cps cps-if ^(condition then else) condition ^(condition)
  (lambda (condition then else)(if condition then else)) condition then else
  ^(thenorelse) thenorelse)

(define-cps cps-find-divisor ^(n d) d ^(d)
  cps-if (cps-< n (cps-* d d)) n
  (cps-if (cps-= (cps-remainder n d) 0) d
    (cps-find-divisor n (cps-+ d 1))))

(define-cps cps-string->number ^(str)
  (lambda (str)(string->number str)) str)

(define-cps cps-car ^(list)
  (lambda (list)(car list)) list)

(define-cps cps-main ^(args)
  cps-car args ^(first)
  cps-string->number first ^(n)
  cps-find-divisor n 2 ^(d)
  cps-print d)
