#|
Hat言語のユーティリティ関数
|#
(include "../sample/native/cui.sch")

( defineCPS fix ^(f) f (fix f) )

( defineCPS #t ^(x y . return)
  return x )

( defineCPS #f ^(x y . return)
  return y )

( defineCPS < ^(a b) a ^(a) b ^(b)
  (lambda (A B)(< A B)) a b )

( defineCPS > ^(a b) a ^(a) b ^(b)
  (lambda (A B)(> A B)) a b )

( defineCPS = ^(a b) a ^(a) b ^(b)
  (lambda (A B)(= A B)) a b )

( defineCPS + ^(a b) a ^(a) b ^(b)
  (lambda (A B)(+ A B)) a b )

( defineCPS - ^(a b) a ^(a) b ^(b)
  (lambda (A B)(- A B)) a b )

( defineCPS * ^(a b) a ^(a) b ^(b)
  (lambda (A B)(* A B)) a b )

( defineCPS remainder ^(a b) a ^(a) b ^(b)
  (lambda (A B)(remainder A B)) a b )

( defineCPS modulo ^(a b) a ^(a) b ^(b)
  (lambda (A B)(modulo A B)) a b )

( defineCPS divMod ^(a b) a ^(a) b ^(b)
  (lambda (A B)(div-and-mod A B)) a b )

( defineCPS if_then_else ^(condition then else)
  condition then else ^(action)
  action )

( defineCPS not ^(condition then else)
  condition else then )

( defineCPS isPair ^(exp)
  (lambda (exp)(pair? exp)) exp )

( defineCPS makePair ^(left right)
  (lambda (left right)(cons left right)) left right )

( defineCPS splitPair ^(pair . return)
  (lambda (pair)(car pair)) pair ^(left)
  (lambda (pair)(cdr pair)) pair ^(right)
  return left right . end )

( defineCPS getFirst ^(list)
  (lambda (list)(car list)) list )

( defineCPS getRest ^(list)
  (lambda (list)(cdr list)) list )

( defineCPS nop ^ return return )

( defineCPS if ^(condition action . return)
  condition action return ^(action)
  action )

( defineCPS unless ^(condition action . return)
  condition return action ^(action)
  action )

( defineCPS moveAll ^(back rest . return)
  unless (isPair back)(return rest) ^()
  getFirst back ^(el)
  getRest back ^(back)
  makePair el rest ^(rest)
  moveAll back rest )

#|
list の各要素を一つずつ選び、その要素を第1引数、
それ以外の要素からなるリストを第2引数とし、
action を呼び出す。
|#
( defineCPS forEach ^(list action . return)
  fix
  ( ^(loop back rest)
    unless (isPair rest) return ^()
    splitPair rest ^(el rest)
;;    getFirst rest ^(el)
;;    getRest rest ^(rest)
    moveAll back rest ^(others)
    action el others ^()
    makePair el back ^(back)
    loop back rest)
  ( ) list )
;;  ( ) list . end ) 2019/7/10 修正

#|
list の要素を非決定的に一つ選び、その要素を第1戻り値、
それ以外の要素からなるリストを第2戻り値として返す。
|#
( defineCPS amb ^(list . cont)
  forEach list cont )

( defineCPS makeString ^(len) len ^(len)
  (lambda (len)(make-string len)) len )

( defineCPS stringSet! ^(str index char . return) index ^(index)
  (lambda (S I C)(string-set! S I C)) str index char ^(dummy)
  return )

( defineCPS stringToNumber ^(str)
  (lambda (str)(string->number str)) str )

( defineCPS listToValues ^(list . return)
  (lambda(L R) (cons R L)) list return ^(exp)
  exp )

( defineCPS gcd ^(a b . return) a ^(a) b ^(b)
  if (= b 0) (return a) ^()
  gcd b (modulo a b) . return )

( defineCPS seqGetCont ^(ifend seq . return)
  seq return . ifend )

#|
数列seqの項を返す。
seqGet seq ^(a rest)
のように一度に一つの項しか取り出せない。
rest: 残りの項からなる数列
省略時の継続は元のままなので、通常の関数と同様に使える。
|#
( defineCPS seqGet ^(seq . return)
  seq ( ^(V . S) return V S )^()
  return seqEnd seqEnd )

;; ( defineCPS seqEnd ^(R) R seqEnd . seqEnd )
( defineCPS seqEnd ^(a) seqEnd )

( defineCPS seqEnd? ^(seq . return)
  ( lambda(S)
    (eq? (if (eq? (car S) 'F.C)
             (car (cdr S)) S)
         'seqEnd)
    ) seq ^(flag)
  return flag
)

( defineCPS listSeq ^(list . return)
  (lambda(L)(cons '^ (cons '(R) (cons (cons 'R L) '(^(R) seqEnd R))))) list ^(seq)
  return seq )

( defineCPS filterSeq ^(filter seq return)
  fix( ^(loop S R)
       seqGet S ^(v s)
       if(seqEnd? s)(seqEnd R)^()
       filter v ^(V)
       R V ^(r)
       loop s r
       ) seq return )

( defineCPS eof? ^(object)
  (lambda(Obj)(eof-object? Obj)) object )

( defineCPS I ^(x . r) r x)

#|
無限数列の例
等差数列
a0: 初項
d: 公差
r0: 数列を受け取る関数
|#
( defineCPS arithSeq ^(a0 d r0)
  fix( ^(loop an rn) an ^(an)
       rn an ^(rn+1)    ; n番目の項を渡す
       loop (+ an d) rn+1
       ) a0 r0
    )

( defineCPS seqFin ^(seq N r . c)
  fix( ^(loop sn n rn cn) n ^(n)
       ifthenelse(< n N)
       ( seqGetCont seqEnd sn ^(an . sn+1)
         rn an ^(rn+1 . cn+1)
         + n 1 ^(n+1)
         loop sn+1 n+1 rn+1 cn+1)
     seqEnd ) seq 0 r c)
