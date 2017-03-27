# Scheme Hat Script

継続渡しスタイルのラムダ計算とSchemeのS式に基づく関数型プログラミング言語のスクリプトインタプリタ

## Language

関数定義

    (define-cps 関数 ^(仮引数 ・・・) 処理)  

関数適用

    関数 実引数 ・・・ ^(変数 ・・・)  

Scheme機能呼び出し

    (lambda ^(仮引数) 処理)

## Usage

    chez/script.sh sch-script.scm min-div.sch 13

## Files

* sch-script.scm  
  Scheme Hat Script用インタプリタ
* min-div.sch  
  Scheme Hat Scriptのサンプルコード  
  2以上の最小の約数を表示する．
* chez/  
  Chez Scheme用スクリプト類
* chicken/  
  Chicken Scheme用スクリプト類
* gambit/  
  Gambit Scheme用スクリプト類
* gauche/  
  Gauche Scheme用スクリプト類
* guile/  
  Guile Scheme用スクリプト類
* test/  
  テスト実行用スクリプト類
* coverage/  
  カバレッジ計測結果用フォルダ
