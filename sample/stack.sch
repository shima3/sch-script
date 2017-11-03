(defineCPS println ^(value)
  (lambda (value)(display value)(newline)'( )) value)

(defineCPS isPair lambda (exp)(display exp)(pair? exp))

(defineCPS makePair lambda (left right)(cons left right))

(defineCPS splitPair ^(pair . return)
  (lambda (pair)(car pair)) pair ^(left)
  (lambda (pair)(cdr pair)) pair ^(right)
  return left right . end)

(defineCPS sendSync ^(actor message . return)
  currentActor ^(from)
  sendAsync actor (message from return) . end)

(defineCPS RplyRqstd ^(message from return context)
  message context ^ reply
  sendAsync from (^(c) actorNext ^( ) reply return))

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
  sendRplySync stack
  (^(list)
    makePair value list ^(list)
    actorBecome list ^()
    actorNext))

(defineCPS stackPop ^(stack)
  sendRplySync stack
  (^(list . return)
    splitPair list ^(value list)
    actorBecome list ^()
    actorNext ^()
    return value . end))

(defineCPS main ^(args)
  makeStack ^(stack)
  (^(a) b) ^(c)
  stackPush stack (a) ^()
  stackPush stack (^(a) b) ^()
  stackPush stack c ^()
  stackIsEmpty stack ^(flag)
  println flag ^()
  stackPop stack ^(value)
  println value ^()
  stackIsEmpty stack ^(flag)
  println flag ^()
  stackPop stack ^(value)
  println value ^()
  stackIsEmpty stack ^(flag)
  println flag ^()
  stackPop stack ^(value)
  println value ^()
  stackIsEmpty stack ^(flag)
  println flag)
