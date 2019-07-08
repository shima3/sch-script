( defineCPS main ^(args)
  test("2") ^()
  test("3") ^()
  test("4") ^()
  test("5") ^()
  test("6") ^()
  test("7") ^()
  test("8") ^()
  test("9") ^()
  end )

( defineCPS test ^(args)
  car args ^(first)
  string_to_number first ^(n)
  find_divisor n 2 ^(d)
  (= n d)
  ( print(n " is a prime number.\n") )
  ( print(n " can be divied by " d ".\n") ) )

(defineCPS main1 ^(args)
  println args)

(defineCPS main2 ^(args)
  car args ^(first)
  println first)

(defineCPS main3 ^(args)
  car args ^(first)
  string_to_number first ^(n)
  println n)

(defineCPS main4 ^(args)
  car args ^(first)
  string_to_number first ^(n)
  n ^(n)
  println n)

(defineCPS main5 ^(args)
  < 13 4 ^(f)
  println f)

(defineCPS main6 ^(args)
  ifthenelse (< 13 4) "aho" "boke" ^(msg)
  println msg)

(defineCPS main7 ^(args)
  find_divisor 13 2 ^(d)
  println d)

(defineCPS main8 ^(args)
  car args ^(first)
  string_to_number first ^(n)
  find_divisor n 2 ^(d)
  println d)

(defineCPS #t ^(a b) a)
(defineCPS #f ^(a b) b)

#; (defineCPS println ^(value)
  (lambda (value)(display value)(newline)) value ^(dummy)( ))

( defineCPS print ^(list . return)
  ( lambda (list)
    (display (string-concatenate (map x->string list)))
    ;; (display (string-append (string-concatenate (map x->string list))))
    ) list ^(dummy)
  return )

(defineCPS println ^(value)
  (lambda (value)
    (display value)
    (newline)) value)

(defineCPS < ^(a b) a ^(a) b ^(b)
  (lambda (A B)(< A B)) a b)

(defineCPS = ^(a b) a ^(a) b ^(b)
  (lambda (A B)(= A B)) a b)

(defineCPS + ^(a b) a ^(a) b ^(b)
  (lambda (A B)(+ A B)) a b)

(defineCPS * ^(a b) a ^(a) b ^(b)
  (lambda (A B)(* A B)) a b)

(defineCPS remainder ^(a b) a ^(a) b ^(b)
  (lambda (A B)(remainder A B)) a b)

(defineCPS ifthenelse ^(condition then else)
  condition then else)

#; (defineCPS if ^(condition then else) condition ^(condition)
  (lambda (condition then else)(if condition then else)) condition then else
  ^(thenorelse) thenorelse)

(defineCPS find_divisor ^(n d) d ^(d)
  ifthenelse (< n (* d d)) n
  ( ifthenelse (= (remainder n d) 0) d
    ( find_divisor n (+ d 1) ) ))

(defineCPS string_to_number ^(str)
  (lambda (str)(string->number str)) str)

(defineCPS car ^(list)
  (lambda (list)(car list)) list)