(defineCPS println ^(value)
  (lambda (value)(display value)(newline)'( )) value)

(defineCPS isPair lambda (exp)(pair? exp))

(defineCPS makePair lambda (left right)(cons left right))

(defineCPS splitPair ^(pair . return)
  (lambda (pair)(car pair)) pair ^(left)
  (lambda (pair)(cdr pair)) pair ^(right)
  return left right . end)

(defineCPS sendSync ^(actor message . return)
  currentActor ^(from)
  ;; sendAsync from (^(c) debugPrint "sendSync 1" ^() actorNext . end) ^()
  ;; debugPrint "sendSync 2" ^()
  sendAsync actor (message from return) . end)

(defineCPS RplyRqstd ^(message from return context . cont)
  message context ^ reply
  ;; debugPrint "RplyRqstd 1" reply ^()
  ;; (^ c debugPrint "c=" c) ^()
  ;; sendAsync from (^ c debugPrint "aho" ^() actorNext . end) ^()
  ;; sendAsync from (^ c println "aho" . end) ^()
  ;; debugPrint "b" ^()
  ;; sendAsync from (^ c debugPrint "d" ^() actorNext . end) ^()
  sendAsync from
  (;; debugPrint "RplyRqstd 2" ^()
    actorNext ^()
    ;; debugPrint "RplyRqstd 3" ^()
    reply return . end) . end)

(defineCPS sendRplySync ^(actor message)
  sendSync actor (RplyRqstd message))

(defineCPS #t ^(then else) then)

(defineCPS #f ^(then else) else)

(defineCPS not ^(condition then else)
  condition else then)

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

(defineCPS reset1 ^(exp . cont)
  exp (^(exp2) exp2 (^(par . cont3) exp (^(exp2 . cont2) cont2 par . cont3)) . cont) . end)
;;  exp (^(exp2) exp2 (^(par) exp (^(exp2 . cont2) exp2 cont2 . end)) . cont) . end)

(defineCPS reset2 ^(exp . cont)
  (^(exp2 . cont2)
    (^(exp3 . cont3) cont2 exp3 . cont3) ^(k)
    exp2 k . cont) ^(shift)
  exp shift . cont)

(defineCPS returnShift ^(stack v)
  stackIsEmpty stack ^(flag)
  flag v (stackPop stack ^(cont) cont v . end))

(defineCPS reset ^(exp . cont)
  makeStack ^(stack)
  stackPush stack cont ^()
  (^(exp2 . cont2)
    (^(exp3 . cont3)
      ;; debugPrint "cont3=" cont3 ^()
      ;; stackPush stack (^(a) b) ^()
      ;; stackPop stack ^(v)
      ;; debugPrint "v=" v ^()
      ;; debugPrint "reset 1" ^()
      stackPush stack cont3 ^()
      ;; debugPrint "reset 2" ^()
      cont2 exp3 . end) ^(k)
    exp2 k ^(v)
    ;; debugPrint "v=" v ^()
    stackPop stack ^(cont4)
    cont4 v . end) ^(shift)
  exp shift ^(v)
  stackPop stack ^(cont5)
  cont5 v . end)

#; (defineCPS reset ^(exp . cont)
  (^(exp2 . cont2) debugPrint "exp2a=" exp2 ^() exp2 cont2) ^(shift2)
  debugPrint "shift2=" shift2 ^()
  (^(par) exp shift2) ^(k)
  debugPrint "k=" k ^()
  (^(exp2) debugPrint "exp2b=" exp2 ^() exp2 k . cont) ^(shift)
  debugPrint "shift=" shift ^()
  exp shift)

(defineCPS + ^(left right) left ^(left) right ^(right)
  (lambda (left right)(+ left right)) left right)

(defineCPS * ^(left right) left ^(left) right ^(right)
  (lambda (left right)(* left right)) left right)

(defineCPS debugPrint lambda args
  (for-each display args)(newline) '())

;;  (lambda (tag value)(display tag)(display value)(newline))
;;  tag value ^(dummy)( ))

(defineCPS main ^(args)
  ;; * 2 (reset (^(shift) + 1 (shift (^(k) k 5)))) ^(value)
  + 1 (reset (^(shift) + 4 (shift (^(k) (* 3 (k 2)))))) ^(value)
  ;; + (+ 1 (reset (^(shift) * (* 2 (shift (^(k) 3))) 4))) 5 ^(value)
  debugPrint "value=" value)
