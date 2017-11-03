(defineCPS fix ^(f) f (fix f))

(defineCPS + ^(left right) left ^(left) right ^(right)
  (lambda (left right)(+ left right)) left right)

(defineCPS #t ^(then else) then)
(defineCPS #f ^(then else) else)

(defineCPS not ^(condition then else) condition else then)

(defineCPS eq? ^(a b)
  (lambda (a b)(eq? a b)) a b)

(defineCPS pair? ^(list)
  (lambda (list)(pair? list)) list)

(defineCPS cons ^(el list)
  (lambda (el list)(cons el list)) el list)

(defineCPS getFirst ^(list)
  (lambda (list)(car list)) list)

(defineCPS getRest ^(list)
  (lambda (list)(cdr list)) list)

(defineCPS moveAll ^(back rest . return)
  unless (pair? back) (return rest) ^()
  getFirst back ^(el)
  getRest back ^(back)
  cons el rest ^(rest)
  moveAll back rest . return)

(defineCPS if ^(condition action) condition ^(condition)
  condition action ())

(defineCPS unless ^(condition action . return)
  condition return action)

#; (defineCPS isEmpty ^(list . return)
  list (^ c eq? c end ^(flag) return flag) ^(a) a . end)

;; (defineCPS getFirst ^(list . return) list (^(a . c) return a))

;; (defineCPS getRest ^(list) (^(a2 . c2) list (^(a . c) c a2 . c2)))

(defineCPS append ^(list1 list2)
  (^(a . c) list1 a ^(a2) list2 a2 . c))

(defineCPS add ^(list el)
  (^(a . c) list a ^(f) f el . c))

(defineCPS print ^(value)
  (lambda (value)(display value)) value ^(dummy)())

(defineCPS newline ^()
  (lambda ()(newline)) ^(dummy)())

(defineCPS println ^(value)
  (lambda (value)(display value)(newline)) value ^(dummy)())

(defineCPS I ^(x) x)

(defineCPS print-list ^(list)
  print "{" ^()
  (isEmpty list)(print "a")(print "b") ^()
  #;(
    print (getFirst list) ^()
    fix
    (^(loop list . break) list ^(list)
      if (isEmpty list) break ^()
      print " " ^()
      print (getFirst list) ^()
      loop (getRest list))
    (getRest list)) ;; ^()
  print "}")

(defineCPS main ^(args)
  '() ^(list1)
  cons 1 list1 ^(list1)
  cons 2 list1 ^(list1)
  cons 3 list1 ^(list1)
  println list1 ^()
  moveAll list1 () ^(list2)
  println list2 ^()
  ())
