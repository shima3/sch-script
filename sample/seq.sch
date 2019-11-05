( include "util.sch" )

#|
数列 a1, a2, a3, ・・・ を
(^(f) f a1 a2 a3 ・・・ . seqEnd)
または
(^(f) f a1 ^(f) f a2 ^(f) f a3 ・・・ . seqEnd)
のように表す。

|#

( defineCPS seqEnd? ^(seq . return)
  ( lambda(S)
    ( if(pair? S)
      ( case (car S)
        ([^] (eq? (car (cdr (cdr S))) 'seqEnd))
        (else #f)
        )
    (eq? S 'seqEnd) )
) seq )

( defineCPS seqNew ^ c
  c )

( defineCPS dlist ^ c
  (^(end) c . end) )

( defineCPS seq1 ^(r)
  r 1 2 3 4 ^(r) seqEnd r )

#|
数列の終端seqEndまで数列の値を出力する。
|#
( defineCPS seqPrintE ^(seq . return)
  fix( ^(loop S)
       seqGet S ^(a nextS)
       if(seqEnd? nextS) return ^()
       print("a" n "=" a "\n")^()
       loop nextS
       ) seq
  )

( defineCPS main2 ^(args)
  print ("start\n") ^()
  seqPrintE seq1 ^()
  print ("end\n") )

( defineCPS main ^(args)
  (seqNew 3 1 4 . seqEnd) ^(seq)
  seqPrintE seq ^()
  print ("end\n") )

( defineCPS main3 ^(args)
  (dlist 3 1 4) ^(dl1)
  (dlist 1 5 9) ^(dl2)
  dl1 (dl2 seqEnd)^(seq)
  seqPrintE seq ^()
  print ("end\n") )

;; １つ目と２つ目以降でreturnの受け取り方が異なるので不採用
( defineCPS seq2 ^ return
  return 1 ^(return2)
  print(return2)^()
  return2 2 3 )

( defineCPS main4 ^(args)
  seq2 ^(a b c)
  print(a "\n")^()
  print(b "\n")^()
  print(c "\n") )
