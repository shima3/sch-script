(defineCPS #t ^(x y) x)
(defineCPS #f ^(x y) y)

#; (defineCPS println ^(value)
  (lambda (value)(display value)(newline)) value ^(dummy)( ))

(defineCPS println lambda (value)
  (display value)
  (newline)
  ())

(defineCPS < ^(left right) left ^(left) right ^(right)
  (lambda (left right)(< left right)) left right)

(defineCPS = ^(left right) left ^(left) right ^(right)
  (lambda (left right)(= left right)) left right)

(defineCPS + ^(left right) left ^(left) right ^(right)
  (lambda (left right)(+ left right)) left right)

(defineCPS * ^(left right) left ^(left) right ^(right)
  (lambda (left right)(* left right)) left right)

(defineCPS remainder ^(left right) left ^(left) right ^(right)
  (lambda (left right)(remainder left right)) left right)

(defineCPS if ^(condition then else) condition ^(condition)
  condition then else ^(choice)
  choice)

#; (defineCPS if ^(condition then else) condition ^(condition)
  (lambda (condition then else)(if condition then else)) condition then else
  ^(thenorelse) thenorelse)

(defineCPS find_divisor ^(n d) d ^(d)
  if (< n (* d d)) n
  (if (= (remainder n d) 0) d
    (find_divisor n (+ d 1))))

(defineCPS string_to_number ^(str)
  (lambda (str)(string->number str)) str)

(defineCPS car ^(list)
  (lambda (list)(car list)) list)

(defineCPS main ^(args)
  car args ^(first)
  string_to_number first ^(n)
  find_divisor n 2 ^(d)
  println d)
