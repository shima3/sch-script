(include "util.sch")
#|
A「Dがやられたようだな…」
B「ククク…奴は我ら四天王の中でも最弱…」
C「私はBよりも弱い…」
A「そして私は最強ではない…」
B「四天王の中に私よりも弱いものが最低でも二人いる…」
C「私はAよりも強い…」
※以上の条件から四天王を強い順に並べよ（5点）
「もうふ@WeAreFloating」より引用
https://twitter.com/WeAreFloating/status/22896320134
|#
( defineCPS main ^(args . return)
  print("begin\n") ^()
  ( amb (1 2 3 4) ^(a r1)
    amb r1 ^(b r2)
    amb r2 ^(c r3)
    amb r3 ^(d r4 . back)
    unless (= d 4) back ^()
    unless (> c b) back ^()
    unless (> a 1) back ^()
    unless (< b 3) back ^()
    unless (< c a) back ^()
    setProperty a "A" ^()
    setProperty b "B" ^()
    setProperty c "C" ^()
    setProperty d "D" ^()
    getProperty 1 "?" ^(no1)
    getProperty 2 "?" ^(no2)
    getProperty 3 "?" ^(no3)
    getProperty 4 "?" ^(no4)
    print(no1 no2 no3 no4 "\n")
    )^()
  print("end\n") )
