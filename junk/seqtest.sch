(include "util.sch")

(defineCPS seqEnd2 ^(R . return)
  return #t . end)

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

(defineCPS main1 ^(args)
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
       read_line ^(line)
       if(eof? line) break ^()
       print(line "\n")^()
       loop . break)^()
  print("End\n"))

#| バグ
seqEnd2?で1行読み込み、
その後seqGet2でもう1行読み込むことになる。
|#
(defineCPS seq3 ^(R . return)
  read_line ^(line . return2)
  if(eof? line)(seqEnd2 R)^()
  R line . seq3)

(defineCPS openSeq ^ return
  read_line ^(line)
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
       )(repeatSeq read_line eof?)^()
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
  repeatSeq2 read_line eof? ^(seq)
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

(defineCPS repeatSeq3 ^(get end?)
  delay (^ return
	  get ^(value)
	  if(end? value)(return seqEnd2)^()
	  repeatSeq3 get end? ^(next)
	  return (^(R) R value . next)))

(defineCPS main6 ^ return
  print("Start\n")^()
  repeatSeq3 read_line eof? ^(seq)
  fix(^(loop seq . break)
       if(seqEnd2? seq) break ^()
       seqGet2 seq ^(first rest)
       print(first "\n")^()
       loop rest . break
       ) seq ^()
  fix(^(loop2 seq . break)
       if(seqEnd2? seq) break ^()
       seqGet2 seq ^(first rest)
       print(first "\n")^()
       loop2 rest . break
       ) seq ^()
  print("End\n")^()
  return)

(defineCPS seqEnd3 ^(R . return)
  return)

(defineCPS seqEnd3? ^(a_seq . return)
  a_seq (return #f)^()
  return #t)

(defineCPS seq4 ^(R)
  R 1 . seqEnd3)

(defineCPS seq5 ^(R)
  R 1 2 . seqEnd3)

(defineCPS seq_get_ex2 ^(seq ex . return)
  seq (^(first . rest)
	return first rest)
  ^() ex . end)

(defineCPS main7 ^ return
  print("start\n")^()
  fix (^(loop seq . break)
	seq_get_ex seq break ^(a rest)
	print(a "\n")^()
	loop rest . break) seq5 ^()
  print("end\n")^()
  return)

(defineCPS seq_arith ^(a d R)
  R a ^(R)
  + a d ^(a)
  seq_arith a d R . end)

(defineCPS seq_arith2 ^(a d R)
  R a ^(R)
  + a d ^(a2)
  seq_arith a2 d R . end)

(defineCPS seq_map ^(f xs r . return)
  seq_get_ex xs return ^(first rest)
  f first ^(v)
  r v ^(r)
  seq_map f rest r . return)

(defineCPS seq_punctuate ^(seq mark R . return)
  seq_get_ex seq return ^(first rest)
  R first ^(R)
  R mark ^(R)
  seq_punctuate rest mark R)

(defineCPS seq_print ^(seq . return)
  seq_get_ex seq return ^(first rest)
  print(first)^()
  seq_print rest)

(defineCPS main8 ^ return
  seq_arith 0 1 ^(seq)
  seq_map (* 2) seq ^(seq)
  seq_punctuate seq "\n" ^(seq)
  seq_print seq ^()
  return)

(defineCPS main9 ^ return
  print("start\n")^()
  seq_print (^(R) R 1 2 3 "\n")^()
  print("end\n")^()
  return)

(defineCPS FC_get ^(fc)
  (lambda(fc)
    (let ([cdr-fc (cdr fc)])
      (values (car cdr-fc)(cdr cdr-fc))
      )) fc)
  
(defineCPS $ ^ return
  FC_get return ^(first rest)
  rest first)

(defineCPS main10 ^ return
  seq_print ($ 1 2 3) ^()
  return)

(defineCPS gc_stat ^ return
  (lambda()(gc-stat))^(s)
  return s)

(defineCPS seq_println ^(seq . return)
  seq_get_ex seq return ^(first rest)
  ;; gc_stat ^(s) print(first " " s "\n")^()
  print(first "  \r")^()
  seq_println rest . return)

(defineCPS main11 ^ return
  seq_println (seq_map (^(x) * 2 x)(seq_arith 0 1))^()
  return)

(defineCPS seq_constant ^(v R . return)
  R v ^(R)
  seq_constant v R . return)

(defineCPS main12 ^ return
  seq_println (seq_constant 0)^()
  return)

(defineCPS gc_total_bytes ^ return
  (lambda()(car (cdr (cdr (cdr (gc-stat))))))^(s)
  return s)

(defineCPS main13 ^ return
  gc_total_bytes ^(s)
  print(s "  \r")^()
  main . return)

(defineCPS seq_empty ^(R . return)
  return #t)

(defineCPS seq_empty?2 ^(seq . return)
  seq (return #f . end) . return)

(defineCPS seq_get_ex2 ^(seq ex . return)
  seq (^(first . rest)
	return first rest)^()
  ex)

(defineCPS seq_get2 ^(seq)
  seq_get_ex seq (print("Error: seq_get empty\n") . end))

(defineCPS seq_ex ^(seq ex r)
  seq_get_ex seq ex ^(first rest)
  r first ^(r2)
  seq_ex rest ex r2)

(defineCPS seq_ex_get ^(seq . return)
  seq return . end)

(defineCPS main14 ^ return
  (^(r) r 1 2 3 ^(r) seq_empty)^(seq)
  seq_get seq ^(a seq)
  print(a "\n")^()
  seq_get seq ^(b seq)
  print(b "\n")^()
  seq_get seq ^(c seq)
  print(c "\n")^()
  return)

(defineCPS main15 ^ return
  (^(r) r 1 2 3 ^(r) seq_empty)^(seq)
  (^(s . r) s r) seq ^(a b c)
  print(a "\n")^()
  print(b "\n")^()
  print(c "\n")^()
  return)

(defineCPS main16 ^ return
  seq_ex (^(r) r 1 2 3 ^(r) seq_empty)(print("Error\n"). end)^(seq)
  seq_ex_get seq ^(a b . rest)
  print(a "\n")^()
  print(b "\n")^()
  print(rest "\n")^()
  seq_ex_get rest ^(c . rest)
  print(c "\n")^()
  ifthenelse(seq_empty? rest)(print("Empty\n"))(print("Not empty\n"))^()
  print(rest "\n")^()
  return)

(defineCPS seq_empty? ^(seq . return)
  seq (return #f))

(defineCPS seq_get_ex ^(seq ex . return)
  seq (^(first . rest)
	return first rest)^(flag)
  print("flag=" flag "\n")^()
  ex)

(defineCPS seq_get ^(seq . return)
  if(seq_empty? seq)
  (print("Error: seq_get empty\n"). end)^()
  seq (^(first . rest)
	if_then_else(seq_empty? rest)
	(return first . seq_empty)
	(return first ^(r)
	  seq_get rest . r))^(flag)
  print("seq_get 3\n"). end)

(defineCPS seq_get2 ^(seq . return)
  seq return . end)

(defineCPS seq_ex ^(seq ex r)
  seq (^(first . rest)
	r first ^(r)
	seq_ex rest ex r)^()
  ex)

(defineCPS main ^(args . return)
  print("start\n")^()
  ;; seq_ex (^(r) r 1 2 . seq_empty)(print("Error: empty\n"). end)^(seq)
  (^(r) r 1 2 . seq_empty)^(seq)

  seq_empty? seq ^(flag) print("empty? " flag "\n")^()
  seq_get seq ^(a b . seq)
  print(a "\n")^()
  print(b "\n")^()

  seq_empty? seq ^(flag) print("empty? " flag "\n")^()
  seq_get seq ^(a b . seq)
  print(a "\n")^()
  print(b "\n")^()

  print("end\n")^()
  return)
