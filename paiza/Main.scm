#|
関数型プログラミング言語 Hat のインタプリタ

入力の1行目はコマンドライン代わり
先頭　Hat言語のソースファイル名
2番目以降　コマンド引数
例
hello.sch

Hat言語のソースファイル .sch
util.sch ユーティリティ関数群
hello.sch 定番 Hello World のサンプルコード
3ple.sch サンプルコード集
4.no.sch 四天王問題のサンプルコード
seq.sch 数列のサンプルコード

Scheme言語のソースファイル .scm
schi.scm インタプリタ本体
wrapper.scm Scheme処理系依存を吸収するための関数群
|#
(add-load-path ".")
(load "wrapper.scm")
(let ((args (cons "schi.scm" (string-tokenize (read-line)))))
    (load (car args))
  (apply main-proc args))
