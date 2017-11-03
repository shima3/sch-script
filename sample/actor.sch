(defineCPS #t ^(x y) x)
(defineCPS #f ^(x y) y)

(defineCPS if ^(condition app)
  condition app ( ))

(defineCPS unless ^(condition app)
  condition ( ) app)

[defineCPS println ^(list)
  { lambda (list)
    (display (string-append (string-concatenate (map x->string list)) "\n"))
    '( ) }
  list]

(defineCPS print ^(value)
  (lambda (value)(display value)'( )) value)

[defineCPS sendAsync ^(actor message)
  let actor
  { mailboxAdd message ^(isFirst)
    if isFirst
    { getBehavior ^(behavior)
      message behavior }}]

[defineCPS sendSync ^(actor message . return)
  currentActor ^(from)
  sendAsync actor { message from return } . end]

[defineCPS RplyRqstd ^(message from return behavior)
  message behavior ^ reply
  let from
  { reply return . end }]

[defineCPS sendRplySync ^(actor message . return)
  sendSync actor { RplyRqstd message }]

[defineCPS AckRqstd ^(message from return behavior)
  start { message behavior } ^( )
  let from { return }]

[defineCPS sendAckSync ^(actor message)
  sendSync actor { AckRqstd message }]

(defineCPS + ^(a b)
  (lambda (a b)(+ a b)) a b)

(defineCPS counter ^(count arg . return)
  + count 1 ^(count)
  println(arg " Start " count) ^( )
  sleepSec 1 ^( )
  actorBecome (counter count) ^( )
  actorNext ^( )
  sleepSec 1 ^( )
  println(arg " End " count) ^( )
  return count . end)

(defineCPS print.reply ^(reply)
  println("reply=" reply))

[defineCPS main ^(args)
  makeActor { counter 0 } ^(a)
  sendAsync a {^(b) println("Async") ^() actorNext . end } ^( )
  println("main 1") ^( )
  sendAsync a {^(b) b "Async" } ^( )
  println("main 2") ^( )
  sendAckSync a {^(b) b "AckSync" } ^( )
  println("main 3") ^( )
  sendAckSync a {^(b) b "AckSync" } ^( )
  println("main 4") ^( )
  sendRplySync a {^(b) b "RplySync"} ^(r)
  println("main 5 reply=" r) ^( )
  sendRplySync a {^(b) b "RplySync"} ^(r)
  println("main 6 reply=" r)]

(defineCPS beforeTime ^(time)
  (lambda (time)(time<? (current-time) time)) time)

(defineCPS #t ^(then else) then)

(defineCPS #f ^(then else) else)

(defineCPS if ^(condition then)
  condition then ( ) ^(action)
  action)

;;  (lambda (condition then else)(if condition then else)) condition then else
;;  ^(thenorelse) thenorelse)

(defineCPS sleepUntil ^(timeout)
  beforeTime timeout ^(flag)
  if flag (sleepUntil timeout))

(defineCPS sleepSec ^(sec) sec ^(sec)
  (lambda (sec)(add-duration (current-time)(seconds->duration sec)))
  sec ^(timeout)
  sleepUntil timeout)
