(defineCPS main ^( )
  start (repeat_at_interval (println "a") 1) ^( )
  start (repeat_at_interval (println "b") 2))

(defineCPS = ^(a b) a ^(a) b ^(b)
  (lambda (a b)(= a b)) a b)

(defineCPS - ^(a b) a ^(a) b ^(b)
  (lambda (a b)(- a b)) a b)

[defineCPS repeat_at_interval_duration ^(exp duration count) count ^(count)
  println count ^( )
  if (= count 0) stop ^( )
  (lambda (d)(add-duration (current-time) d)) duration ^(timeout)
  exp ^( )
  sleep_until timeout ^( )
  repeat_at_interval_duration exp duration {- count 1}]

(defineCPS repeat_at_interval ^(exp sec)
  #; (lambda (sec)
    (let ((s (floor sec)))
      (let ((ns (- sec s)))
	(set! ns (floor (* ns 1000000000)))
  (make-time 'time-duration ns s))))
  (lambda (sec)(seconds->duration sec)) sec ^(duration)
  repeat_at_interval_duration exp duration 10)

(defineCPS println ^(value)
  (lambda (value)(display value)(newline)) value ^(dummy)
  '( ))

(defineCPS #t ^(then else) then)
(defineCPS #f ^(then else) else)

(defineCPS if ^(condition then) condition ^(condition)
  condition then ( ) ; ^(action) action
  )

#; (defineCPS if ^(condition then else) condition ^(condition)
  (lambda (condition then else)(if condition then else)) condition then else
  ^(thenorelse) thenorelse)

(defineCPS before_time ^(time)
  (lambda (time)(time<? (current-time) time)) time)

[defineCPS sleep_until ^(timeout)
  before_time timeout ^(flag)
  if flag { sleep_until timeout }]

(defineCPS sleep_sec ^(sec) sec ^(sec)
  (lambda (sec)(add-duration (current-time)(seconds->duration sec)))
  sec ^(timeout)
  sleep_until timeout)
