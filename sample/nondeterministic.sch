(defineCPS fix ^(f) f (fix f))

(defineCPS #t ^(then else) then)
(defineCPS #f ^(then else) else)

(defineCPS not ^(condition then else) condition else then)

(defineCPS isPair ^(exp)
  (lambda (exp)(pair? exp)) exp)
;; (defineCPS isPair lambda (exp)(pair? exp))

(defineCPS makePair ^(left right)
  (lambda (left right)(cons left right)) left right)

(defineCPS splitPair ^(pair . return)
  (lambda (pair)(car pair)) pair ^(left)
  (lambda (pair)(cdr pair)) pair ^(right)
  return left right . end)

#; (defineCPS cons ^(el list)
  (lambda (el list)(cons el list)) el list)
#; (defineCPS cons lambda (el list)(cons el list))

(defineCPS getFirst ^(list)
  (lambda (list)(car list)) list)
#; (defineCPS getFirst lambda (list)(car list))

(defineCPS getRest ^(list)
  (lambda (list)(cdr list)) list)
#; (defineCPS getRest lambda (list)(cdr list))

#; (defineCPS eq? ^(a b)
  (lambda (a b)(eq? a b)) a b)

(defineCPS if ^(condition action . return)
  condition action return)

(defineCPS unless ^(condition action . return)
  condition return action)

(defineCPS print ^(value)
  (lambda (value)(display value)) value ^(dummy)())

(defineCPS newline ^()
  (lambda ()(newline)) ^(dummy)())

(defineCPS println ^(value)
  (lambda (value)(display value)(newline)) value ^(dummy)( ))

(defineCPS moveAll ^(back rest . return)
  unless (isPair back) (return rest . end) ^()
  getFirst back ^(el)
  getRest back ^(back)
  makePair el rest ^(rest)
  moveAll back rest)

;; list から要素を1つ選び、第1引数とし、残りを第2引数とし action を呼び出す。
(defineCPS forEach ^(list action . return)
  fix
  (^(loop back rest)
    unless (isPair rest)(return . end) ^()
    splitPair rest ^(el rest)
;;    getFirst rest ^(el)
;;    getRest rest ^(rest)
    moveAll back rest ^(others)
    action el others ^()
    makePair el back ^(back)
    loop back rest)
  () list . end)

(defineCPS main1 ^(args)
  println "begin" ^()
  forEach (1 2 3 4 5)
  (^(someone others)
    print someone ^()
    print " " ^()
    println others) ^()
  println "end")

(defineCPS forAnyOrder ^(list action)
  fix
  (^(loop selected candidate)
    (isPair candidate)
    (forEach candidate
      (^(someone others)
	makePair someone selected ^(selected)
	loop selected others))
    (moveAll selected () ^(selected)
      action selected))
  () list)

(defineCPS main2 ^(args)
  println "begin" ^()
  forAnyOrder (1 2 3 4)
  (^(selected)
    println selected) ^()
  println "end")

(defineCPS amb ^(list cont . k)
  forEach list k . cont)

;;  k 1 (2 3) ^()
;;  k 2 (1 3) ^()
;;  k 3 (1 2) . cont)

(defineCPS main3 ^(args)
  println "begin" ^()
  (^ cont
    amb (1 2 3 4) cont ^(a rest . cont)
    amb rest cont ^(b rest . cont)
    amb rest cont ^(c rest . cont)
    amb rest cont ^(d rest . cont)
    print a ^()
    print b ^()
    print c ^()
    print d ^()
    newline . cont) ^()
  println "end")

(defineCPS sendSync ^(actor message . return)
  currentActor ^(from)
  sendAsync actor (message from return) . end)

(defineCPS RplyRqstd ^(message from return context . cont)
  message context ^ reply
  sendAsync from (actorNext ^() reply return . end) . end)

(defineCPS sendRplySync ^(actor message)
  sendSync actor (RplyRqstd message))

(defineCPS makeStack ^()
  makeActor ())

(defineCPS stackIsEmpty ^(stack)
  sendRplySync stack
  (^(list)
    isPair list ^(flag)
    actorNext ^()
    not flag))

(defineCPS stackPush ^(stack value)
  ;; println "stackPush 1" ^()
  sendRplySync stack
  (^(list . cont)
    ;; println "stackPush 2" ^()
    makePair value list ^(list)
    ;; println "stackPush 3" ^()
    actorBecome list ^()
    ;; println "stackPush 4" ^()
    actorNext . cont
    ))

(defineCPS stackPop ^(stack)
  ;; debugPrint "stackPop 1" ^()
  sendRplySync stack
  (^(list . return)
    splitPair list ^(value list)
    actorBecome list ^()
    actorNext ^()
    return value . end))

(defineCPS reset ^(exp . cont)
  makeStack ^(stack)
  stackPush stack cont ^()
  (^(exp2 . cont2)
    (^(exp3 . cont3)
      stackPush stack cont3 ^()
      cont2 exp3 . end) ^(k)
    exp2 k ^(v)
    stackPop stack ^(cont4)
    cont4 v . end) ^(shift)
  exp shift ^(v)
  stackPop stack ^(cont5)
  cont5 v . end)

#; (defineCPS reset ^(exp . cont)
  exp (^(exp2) exp2 (^ cont3 exp (^(exp2 . cont2) cont3 cont2)) . cont) . end)

#|
listから１つ要素を選び、その要素と残りのリストを返す。
|#
(defineCPS amb2 ^(shift list)
  shift
  (^(k)
    forEach list
    (^(first rest)
      makePair first rest ^(p)
      k p) ^()
    "dummy") ^(p)
  splitPair p)

(defineCPS main4 ^(args)
  println "main 1" ^()
  reset
  (^(shift)
    println "main 2" ^()
    amb2 shift (1 2 3 4) ^(a r)
    println "main 3" ^()
    amb2 shift r ^(b r)
    println "main 4" ^()
    amb2 shift r ^(c r)
    println "main 5" ^()
    amb2 shift r ^(d r)
    println "main 6" ^()
    print a ^()
    print b ^()
    print c ^()
    print d ^()
    newline ^()
    "a") ^(v)
  println "main 7")

(defineCPS makeAmb ^(exp)
  reset
  (^(shift)
    exp (amb2 shift)))

(defineCPS main ^(args)
  println "main 1" ^()
  makeAmb
  (^(amb)
    println "main 2" ^()
    amb (1 2 3 4) ^(a r)
    println "main 3" ^()
    amb r ^(b r)
    println "main 4" ^()
    amb r ^(c r)
    println "main 5" ^()
    amb r ^(d r)
    println "main 6" ^()
    print a ^()
    print b ^()
    print c ^()
    print d ^()
    newline) ^()
  println "main 7")
