(include "util.sch")

(defineCPS seqEnd2 ^(R . return)
  return #t)

(defineCPS seqEnd2? ^(aSeq . return)
  aSeq (return #f) . return)

(defineCPS seqGet2 ^(aSeq . return)
  aSeq (^(first . restSeq)
	 return first restSeq)
  . end)

(defineCPS seq1 ^(R)
  R 1 2 3 . seqEnd2)

(defineCPS seq2 ^(R)
  R 1 ^(R)
  R 2 ^(R)
  R 3 . seqEnd2)

(defineCPS main ^(args)
  print("Start\n")^()
  fix(^(loop seq . break)
       if(seqEnd2? seq) break ^()
       seqGet2 seq ^(first restSeq)
       print(first "\n")^()
       loop restSeq . break
       ) seq3 ^()
  print("End\n"))

(defineCPS main2 ^(args)
  print("Start\n")^()
  fix(^(loop . break)
       readLine ^(line)
       if(eof? line) break ^()
       print(line "\n")^()
       loop . break)^()
  print("End\n"))

#| バグ
seqEnd2?で1行読み込み、
その後seqGet2でもう1行読み込むことになる。
|#
(defineCPS seq3 ^(R . return)
  readLine ^(line . return2)
  if(eof? line)(seqEnd2 R)^()
  R line . seq3)

(defineCPS openSeq ^ return
  readLine ^(line)
  if(eof? line)(return seqEnd2)^()
  return (^(R) R line . openSeq))

(defineCPS main3 ^(args)
  print("Start\n")^()
  fix(^(loop seq . break)
       seq ^(seq)
       if(seqEnd2? seq) break ^()
       seqGet2 seq ^(first restSeq)
       print(first "\n")^()
       loop restSeq . break
       ) openSeq ^()
  print("End\n"))

(defineCPS repeatSeq ^(get end? . return)
  get ^(value)
  if(end? value)(return seqEnd2)^()
  return (^(R) R value ^() repeatSeq get end?))

(defineCPS main4 ^(args)
  print("Start\n")^()
  fix(^(loop readSeq . break)
       readSeq ^(seq)
       if(seqEnd2? seq) break ^()
       seqGet2 seq ^(first restSeq)
       print(first "\n")^()
       loop restSeq . break
       )(repeatSeq readLine eof?)^()
  print("End\n"))

(defineCPS memo ^(call)
  (lambda(call)
    (let ([dst (cons call ())])
      (let ([qdst (cons 'quote (cons dst ()))])
	(let ([body (list 'copy-cell qdst 'src)])
	  (let ([copyCell (list 'lambda '(src) body)])
	    (set-cdr! dst (list '^ '(src) copyCell 'src))
	    qdst))))) call)

(defineCPS repeatSeq2 ^(get end?)
  memo (^ return
	 get ^(value)
	 if(end? value)(return seqEnd2)^()
	 repeatSeq2 get end? ^(next)
	 return (^(R) R value . next)))

(defineCPS main5 ^(args)
  print("Start\n")^()
  repeatSeq2 readLine eof? ^(seq)
  ;; print("main 1\n")^()
  fix(^(loop seq . break)
       ;; print("main 2 " seq "\n")^()
       if(seqEnd2? seq) break ^()
       ;; print("main 3 " seq "\n")^()
       seqGet2 seq ^(first rest)
       ;; print("main 4\n")^()
       print(first "\n")^()
       loop rest . break
       ) seq ^()
  print("End\n"))
