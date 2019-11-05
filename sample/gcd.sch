( include "util.sch" )

#|
aとbの最大公約数を返す関数
|#
( defineCPS gcd ^(a b . return) a ^(a) b ^(b)
  if( = b 0 )( return a )^()
  gcd b ( modulo a b ) . return )

#|
aとbの最大公約数を返す関数
|#
( defineCPS gcd2 ^(a b) b ^(b)
  ifthenelse(= b 0) a
  (gcd2 b (modulo a b) ) )

#|
15と6の最大公約数を出力するプログラム
|#
( defineCPS main ^(args)
  15 ^(a) 6 ^(b)
  gcd a b ^(c)
  print(a "と" b "の最大公約数は" c "です。\n") )

#|
15と6の最大公約数を出力するプログラム
|#
( defineCPS main2 ^(args)
  15 ^(a) 6 ^(b)
  fix( ^(loop n . break)
       gcd2 a b ^(c)
       + n 1 ^(n)
       if(= n 4000)(break c)^()
       loop n
       ) 0 ^(c)
  print(a "と" b "の最大公約数は" c "です。\n") )
