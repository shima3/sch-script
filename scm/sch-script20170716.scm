;; Scheme処理系依存を吸収するためのユーティリティ関数
(define (cons-alist key datum alist)(cons (cons key datum) alist))
(define (eval1 expr)(eval expr (interaction-environment)))
(define (println first . rest)
  (display first)
  (if (null? rest)
    (newline)
    (apply println rest)
    )
  )

;; 大域変数用ハッシュ表
(define cps-env (make-eqv-hashtable))
;; (define cps-env (make-hash-table)) ;; 2017/7/13 bug 

;; 大域変数 var の値を返す。
(define (get-global-var var)
  (hash-table-ref/key cps-env var)
  )

;; 項 term を値とする変数 var を定義する．
(define (set-global-var var term)
  (hash-table-set! cps-env var term))

;; インタプリタによる式の評価を繰り返すかどうかを示すフラグ
(define loop-flag #t)

;; インタプリタを停止する．
(define (interpreter-stop!)
  (set! loop-flag #f)
  )

;; 終了コード
(define exit-code 0)

;; キューを作る
(define (make-queue)
  (cons '( ) '( )))

#|
キュー queue に要素 el を追加する
追加して要素数が１の場合，戻り値は #t
追加して要素数が２つ以上の場合，戻り値は #f
|#
(define (enqueue! queue el)
  (let ((first (car queue))(last (cdr queue))(new-last (cons el '( ))))
    (if (null? first)
      (set-car! queue new-last)
      (set-cdr! last new-last))
    (set-cdr! queue new-last)
    (null? first)
    )
  )

;; キュー queue から要素を取り出す
(define (dequeue! queue)
  (let ((first (car queue)))
    (if (null? first)
      '( )
      (begin
	(set-car! queue (cdr first))
	(car first)))
    )
  )

;; キュー queue が空かどうか判定する
(define (queue-empty? queue)
  (null? (car queue)))

;; キュー queue の要素が１つだけかどうか判定する
(define (queue-one? queue)
  (eq? (car queue)(cdr queue)))

(define (queue-peek queue)
  (let ((first (car queue)))
    (if (null? first)
      '( )
      (car first))))

;; スレッドセーフなキューを作る
(define (make-mt-queue)
  (cons (make-mutex)(make-queue)))

;; スレッドセーフなキュー queue に要素 el を追加する
(define (mt-enqueue! queue el)
  (let ((mutex (car queue)))
    (mutex-lock! mutex)
    (let ((flag (enqueue! (cdr queue) el)))
      (mutex-unlock! mutex)
      flag
      )
    )
  )

;; スレッドセーフなキュー queue から要素を取り出す
(define (mt-dequeue! queue)
  (let ((mutex (car queue))(el '( )))
    (mutex-lock! mutex)
    (set! el (dequeue! (cdr queue)))
    (mutex-unlock! mutex)
    el)
  )

;; スレッドセーフなキュー queue が空かどうか判定する
(define (mt-queue-empty? queue)
  (queue-empty? (cdr queue)))

(define (mt-queue-peek queue)
  (queue-peek (cdr queue)))

;; (define test-queue (make-mt-queue))
;; (mt-enqueue! test-queue "aho 1")
;; (mt-enqueue! test-queue "boke 2")
;; (println (mt-dequeue! test-queue))
;; (println (mt-dequeue! test-queue))

;; built-in function: make.queue ^(queue)
;; キューを作り，queue に渡す
(set-global-var 'make.queue
  `(lambda args
     (cons 'quote (make-mt-queue))))

;; built-in function: enqueue queue el ^( )
;; キュー queue に要素 el を追加する
(set-global-var 'enqueue
  `(lambda (queue el)
     (mt-enqueue! (cdr queue) el)
     '( )))

;; built-in function: dequeue queue ^(el)
;; キュー queue から要素を取り出し，el に渡す
(set-global-var 'dequeue
  `(lambda (queue)
     (mt-dequeue! (cdr queue))))

;; 現在のアクターを返す
(define (current-actor)
  (current-thread-specific)
  )

;; built-in function: currentActor ^(actor)
;; 現在のアクターを actor に渡す
(set-global-var 'currentActor
  '(lambda ( )(cons 'quote (current-actor))))

;; actor を現在のアクターとして設定する
(define (current-actor-set! actor)
  (current-thread-specific-set! actor))
;;  (thread-specific-set! (current-thread) actor))

;; 計算過程のキュー
;; 計算過程は関数適用とアクターの組で表現される
(define app-queue (make-mt-queue))

;; 関数適用 app とアクター actor の組を計算過程のキューに追加する
(define (app-enqueue! app actor)
  ;; (println "app-enqueue! 1 " app)
  (mt-enqueue! app-queue (cons app actor))
  ;; (println "app-enqueue! 2 " app)
  )

;; built-in function: start app ^( )
;; 関数適用 app の計算を開始する
(set-global-var 'start
  '(lambda (app)
     ;; (println "start 1")
     (app-enqueue! app (current-actor))
     ;; (println "start 2")
     '( )))

;; 計算過程のキューから関数適用とアクターの組を取り出す
(define (app-dequeue!)
  (mt-dequeue! app-queue))

;; アクターを作る
(define (make-actor behavior)
  (cons behavior (make-mt-queue)))

;; built-in function: makeActor behavior ^(actor)
;; 動作 behavior を行うアクターを作り，actor に渡す
(set-global-var 'makeActor
  '(lambda (behavior)
     (cons 'quote (make-actor behavior))))

;; アクター actor の動作を behavior に変更する
(define (actor-become actor behavior)
  (set-car! actor behavior))

;; built-in function: actorBecome behavior
;; 現在のアクターの動作を behavior に変更する
(set-global-var 'actorBecome
  '(lambda (behavior)
     (actor-become (current-actor) behavior)
     '( )))

;; アクター actor 宛てのメッセージのキューからメッセージを１つ取り出し，actor に実行させる
(define (actor-respond actor)
  ;; (display "actor-respond 1 ")(display actor)(newline)
  (let ([context (car actor)][queue (cdr actor)])
    (let ([message (mt-queue-peek queue)])
      ;; (display "actor-respond 2 ")(display message)(newline)
      (if (not (null? message))
	(begin
	  (app-enqueue! (list message context) actor)
	  ;; (display "actor-respond 3 ")(display actor)(newline)
	  )
	)))
  ;; (display "actor-respond 4 ")(display actor)(newline)
  )
#; (define (actor-respond actor)
  (let ((behavior (car actor))(queue (cdr actor)))
    (let ((message (mt-dequeue! queue)))
      (if (not (null? message))
	  (app-enqueue! (list message behavior) actor)
	)
      )
    )
  )

;; 現在のアクターに次のメッセージを実行させる
(set-global-var 'actorNext
  '(lambda ( )
     ;; (display "actorNext 1")(newline)
     (let ([actor (current-actor)])
       (let ([queue (cdr actor)])
	 (mt-dequeue! queue)
	 (if (not (mt-queue-empty? queue))
	     (actor-respond actor))))
     ;; (display "actorNext 2")(newline)
     '( )))

;; アクター actor にメッセージ message を送信する
(define (send actor message)
  ;; (display "send")(newline)
  ;; (display (cdr (cdr actor)))(newline)
  (if (mt-enqueue! (cdr actor) message)
    (actor-respond actor))
  )

;; quote つきアクター qActor に非同期メッセージ message を送信する
(set-global-var 'sendAsync
  '(lambda (qActor message)
     ;; (display "sendAsync")(display message)(newline)
     (send (cdr qActor) message)
     '( )))

;; インタプリタの個数
(define interpreter-count 0)
;; interpreter-count 用の mutex
(define interpreter-mutex (make-mutex))
;; インタプリタの最大数
(define max-interpreter-count 1)

;; インタプリタの個数を１つ増やす（スレッドセーフ）
(define (interpreter-count-add! n)
  (mutex-lock! interpreter-mutex)
  (set! interpreter-count (+ interpreter-count n))
  (mutex-unlock! interpreter-mutex)
  )

;; ユーザによって定義された main を最初に呼び出す．
(define entry-point 'main)

;; 0.1秒の時間間隔
(define duration100ms (seconds->duration 0.1))

;; プログラムを解釈し，実行する．
;; args：コマンドラインの引数のリスト
;; [-e entry-point] script argument ...
(define (interpret args)
  (let loop ( )
    (if (pair? args)
      (let ((arg (car args)))
	(if (equal? (string-ref arg 0) #\-)
	  (let ((opt (string-ref arg 1)))
	    (case opt
	      ((#\e)
	       (set! entry-point (substring arg 2 (string-length arg)))
	       (if (equal? entry-point "")
		   (begin
		     (set! args (cdr args))
		     (set! entry-point (car args))))
	       (set! entry-point (string->symbol entry-point))
	       ))
	    (set! args (cdr args))
	    (loop))))))
  (load-sch-script (car args))
  ;; (app-enqueue! (cons entry-point (cons (cdr args) '(^() exit 0 . end)))
  (app-enqueue! (list entry-point (cdr args) '^ '() 'exit 0)
  ;; (app-enqueue! (list entry-point (cdr args))
    (make-actor "main"))
  (let loop2 ( )
    (if (< interpreter-count max-interpreter-count)(interpreter-start!))
    (sleep duration100ms)
    ;; (if (not (mt-queue-empty? app-queue)) (loop2)))
    (if loop-flag (loop2)))
  (let loop3 ( )
    (sleep duration100ms)
    (if (> interpreter-count 0)(loop3))
    )
  (exit exit-code))

;; sch-script 言語のファイル filename を読み込む
(define (load-sch-script filename)
  (call-with-input-file filename
    (lambda (port)
      (let loop ( )
	(if (interpret-sexp (read port))
	  (loop))))))

;; インタプリタを開始する
(define (interpreter-start!)
  (fork-thread
    (lambda ( )
      (interpreter-count-add! 1)
      (let ( (timeout (add-duration (current-time) duration100ms))
	     (app-actor (app-dequeue!)) )
	(if (not (null? app-actor))
	  (let ([actor (cdr app-actor)])
	    ;; (println "interpreter-start! 1 app-actor=" app-actor)
	    (current-actor-set! actor)
	    ;; (println "interpreter-start! 2 app-actor=" app-actor)
	    (let loop ([app (car app-actor)])
	      ;; (println "interpreter-start! app=" app)
	      (if (not (null? app))
		(if (time<? (current-time) timeout)
		  (loop (step-app app))
		  (app-enqueue! app actor)))
	      )
	    ))
	)
      (interpreter-count-add! -1)
      )))

;; S式 sexp を解釈し，実行する．
(define (interpret-sexp sexp)
  (cond
    ((pair? sexp)(interpret-command (car sexp)(cdr sexp)) #t)
    ((eof-object? sexp) #f)
    (else #t)))

;; コマンド cmd，引数 args を解釈し，実行する．
(define (interpret-command cmd args)
  (case cmd
    ((defineCPS)(set-global-var (car args)(cdr args)))))

;; 関数適用 app を一段階実行する．
(define (step-app app)
  (let ((func (car app))(args (cdr app)))
    (set! func (get-global-var func))
    (cond
      ((pair? func)
	(let ((first (car func))(rest (cdr func)))
	  (case first
	    ((^)(step-abs (car rest)(cdr rest) args '( )))
	    ((lambda)
	      (apply-func func (pickup-cont-arg args)))
	    ((quote)
	      (list args (car rest)))
	    (else
	      (substitute-term func '( ) args))
	      ;; bug (cons (cons '^ (cons '($0) (cons '$0 func))) args))
	      ;; bug? (substitute-term func cps-env args))
	    )))
      ((not (pair-terms? args))
	;; (println "step-app 2")
	(list args func))
      ((null? func) '( ))
      (else
	(display "Illegal function error: ")
	(write app)
	(newline)
	(exit 1)))))

;; parsとappからなるラムダ抽象にargsを与えて一段階実行する。
;; pars 仮引数
;; app 関数適用
;; args 実引数
;; env 変数環境
(define (step-abs pars app args env)
  (if (pair? pars)
    (if (pair-terms? args)
      (step-abs (cdr pars) app (cdr args)(cons-alist (car pars)(car args) env))
      (list args (cons '^ (cons pars (substitute-term app env '( ))))))
    (begin
      (if (pair-terms? args)
	(set! args (cons '^ (cons '($0)(cons '$0 args)))))
      (if (not (null? pars))
	(set! env (cons-alist pars args env)))
      (substitute-term app env args))))

;; termがpairならば #t、そうでなければ #f を返す。
(define (pair-terms? term)
  (and (pair? term)
    (case (car term)
      ((^ lambda quote) #f)
      (else #t))))

;; 環境 env における変数 var の値を返す。
(define (get-var var env)
  (let ((kv (assq var env))) ; assoc -> assq 2017/3/28
    (if kv (cdr kv) var)))

;; 通常の順序の引数リストを継続第一にして返す。
;; 通常の順序 (引数1 引数2 … . 継続) -> 継続第一 (継続 引数1 引数2 …)
;; このとき大域変数を値に置き換える。
;; (define (pickup-cont-arg args env)
(define (pickup-cont-arg args)
  (if (pair-terms? args)
    (let ((cargs (pickup-cont-arg (cdr args))))
      (cons (car cargs)(cons (get-global-var (car args))(cdr cargs))))
    (list (get-global-var args))
  ))

;; 関数 func に継続第一の引数リスト cargs を適用する。
(define (apply-func func cargs)
  ;; (println "apply-func cargs=" cargs)
  (list (car cargs)(apply (eval1 func)(cdr cargs))))

;; 項 term に含まれる変数を env で対応づけられた値に置き換える。
;; env 環境（変数と値との対応）
;; defcont 省略時継続
(define (substitute-term term env defcont)
  (cond
    ((pair? term)
      (let ((first (car term))(rest (cdr term)))
	(case first
	  ((^)(substitute-abs (car rest)(cdr rest) env defcont))
	  ((lambda) term)
	  ((quote) term)
	  (else
	    (cons (substitute-term first env '( ))
	      (substitute-term rest env defcont))
	    ))))
    ((null? term) defcont)
    (else (get-var term env))))

;; 仮引数列 pars、関数適用 app からなるラムダ抽象に含まれる変数を env で対応づけられた値に置き換える。
(define (substitute-abs pars app env defcont)
  (cons '^ (cons pars (substitute-term app (assign-self pars env) defcont))))

;; 仮引数列 pars の各仮引数に対し、その仮引数自身を値として割り当てた対応を環境 env に追加した環境を返す。
;; 束縛変数が substitute-abs において外部の変数の値に置き換えられることを防ぐ。
(define (assign-self pars env)
  (cond
    ((pair? pars)(assign-self (cdr pars)(assign-self (car pars) env)))
    ((null? pars) env)
    (else (cons-alist pars pars env))))

;; コマンド引数を与えてインタプリタを呼び出す。
(define (main-proc cmd . args)
  (interpret args)
  )

;; ----- built-in functions -----

#|
end
式の終端
|#
(set-global-var 'end '( ))

#|
exit code
スクリプトを終了する
code: 終了コード
|#
(set-global-var 'exit
  `(^(code)
     (lambda (code)
       (set! exit-code code)
       (interpreter-stop!)) code . end))
