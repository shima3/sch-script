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

;; built-in functions を定義する大域変数用ハッシュ表
;; (define cps-env (make-eqv-hashtable))
(define cps-env (make-hash-table))

;; 大域変数 var の値を返す。
(define (get-global-var var)
;;  (hash-table-get cps-env var var))
  (hash-table-ref/default cps-env var var))
;;  (hashtable-ref cps-env var var))

;; 項 term を値とする変数 var を定義する．
(define (set-global-var var term)
;;  (hash-table-put! cps-env var term))
  (hash-table-set! cps-env var term))
;;  (hashtable-set! cps-env var term))
  ;; (set! cps-env (cons-alist var term cps-env)))

(set-global-var 'cps-exit
  '(lambda args
     (if (pair? args)
       (let ((value (car args)))
	 (if (number? value)(exit value))))
     (exit 0))
  )

;; ユーザによって定義された cps-main を最初に呼び出す．
(define entry-point 'cps-main)

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
  (call-with-input-file (car args)
    (lambda (port)
      (let loop3 ( )
	(if (interpret-sexp (read port))
	  (loop3)))))
  (let loop2
      ((app (cons entry-point (cons (cdr args) 'cps-exit))))
    (if (pair? app)(loop2 (step-app app))))
)

;; S式 sexp を解釈し，実行する．
(define (interpret-sexp sexp)
  (cond
    ((pair? sexp)(interpret-command (car sexp)(cdr sexp)) #t)
    ((eof-object? sexp) #f)
    (else #t)))

;; コマンド cmd，引数 args を解釈し，実行する．
(define (interpret-command cmd args)
  (case cmd
    ((define-cps)(set-global-var (car args)(cdr args)))))

;; 関数適用 app を一段階実行する．
(define (step-app app)
;;  (println "app=" app)
  (let ((func (car app))(args (cdr app)))
    ;; (set! func (get-var func cps-env))
    (set! func (get-global-var func))
    (cond
      ((pair? func)
	(let ((first (car func))(rest (cdr func)))
	  (case first
	    ((^)(step-abs (car rest)(cdr rest) args '( )))
	    ((lambda)
	      (apply-func func (pickup-cont-arg args)))
	      ;; (apply-func func (pickup-cont-arg args cps-env)))
	    ((quote)(list args (car rest)))
	    (else (substitute-term func '( ) args))
	      ;; bug? (substitute-term func cps-env args))
	    )))
      ((not (pair-terms? args))(list args func))
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
      ((^ lambda) #f)
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
    ;; (let ((cargs (pickup-cont-arg (cdr args) env)))
    (let ((cargs (pickup-cont-arg (cdr args))))
      (cons (car cargs)(cons (get-global-var (car args))(cdr cargs))))
      ;; (cons (car cargs)(cons (get-var (car args) env)(cdr cargs))))
    (list (get-global-var args))
    ;; (list (get-var args env))
  ))

;; 関数 func に継続第一の引数リスト cargs を適用する。
(define (apply-func func cargs)
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
	  ((lambda quote) term)
	  (else (cons (substitute-term first env '( ))
		  (substitute-term rest env defcont))))))
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
(interpret (command-line-arguments))
;; (display (command-line-arguments))(newline)
