# Scheme Hat Script

継続渡しスタイルのラムダ計算とSchemeに基づく関数型スクリプト言語

## Description

ラムダ計算はチューリング完全で最も単純な計算モデルの1つであり、関数型プログラミング言語の理論的基礎となっています。
継続渡しスタイルは例外処理や多重ループからの脱出などの制御構造を表現したり、処理の最適化や並列化のためコンパイラの中間言語として利用されています。

本提案言語は関数型プログラミング言語の学習を目的とし、継続渡しスタイルのラムダ計算を簡潔に記述する記法を用いることによって、最小の文法で最大の表現力を目指しています。
このminimalismの設計方針、および、継続渡しスタイルが可能である点はSchemeと同様です。
ただし、Schemeは直接スタイルを基本とし、必要に応じて継続を取り出すので、継続渡しスタイルが複雑になります。
また、同じアルゴリズムであっても直接スタイルと継続渡しスタイルとは別々に扱う必要があります。
提案言語では直接スタイルは継続渡しスタイルにおける継続の引数を省略した形とみなすので、継続渡しスタイルと統一的に扱うことができます。

## Features

* ラムダ計算  
チャーチ数、不動点コンビネータ、部分適用などラムダ計算を忠実に実行できます。

* 継続渡しスタイル  
順次処理、選択処理、反復処理などの基本的な制御構造から、複数の戻り値、例外処理、多重ループからの脱出、さらに高度な制御構造までプログラマが関数として定義することが可能です。

* 外部関数呼出し  
速度が要求される演算や入出力のため、Schemeの処理系が持つ関数を呼び出すことが可能です。

## Language

次のサンプルコードは Hello, World! を表示します。

    (define-cps main ^(args)
      println "Hello, World!"
      )

define-cps は次の書式で関数を定義します。

    (define-cps 関数名 関数定義)

関数名は１つの変数で、変数の厳密な書式は使用する Scheme 処理系に依存しますが、主に英数字からなる文字列です。
ただし、関数名 main はプログラムを実行したとき、最初に呼び出される関数を示します。
関数定義は次の書式で基本的な計算を示します。

    ^(仮引数列 . 継続仮引数) 関数 引数列 . 継続引数

仮引数列は変数の列、継続仮引数は１つの変数です。
関数と継続引数は１つの項、引数列は項の列です。
上記のサンプルコードの場合、args が仮引数、println が関数、"Hello, World!" が引数です。

複数の変数は空白で区切ります。
項は変数または括弧で囲んだ関数定義です。
継続仮引数または継続引数の前のピリオドの前後には空白が必要です。

仮引数が必要ない場合、次のように記述します。

    ^継続仮引数 関数 引数列 . 継続引数

継続仮引数が必要ない場合、次のように記述します。

    ^( ) 関数 引数列 . 継続引数

引数列が必要ない場合、次のように記述します。

    ^(仮引数列 . 継続仮引数) 関数 . 継続引数

継続引数が継続仮引数と同じ場合、継続引数を次のように省略できます。

    ^(仮引数列 . 継続仮引数) 関数 引数列

上記のサンプルコードの関数定義 `^(args) println "Hello, World!"` は `^(args . c) println "Hello, World!" . c` の継続仮引数と継続引数を省略しています。
関数 main を呼び出すとき、戻り先が継続仮引数 c に渡され、`println "Hello, World!"` を実行した後、c を呼び出します。

継続引数として関数定義を渡す場合、ピリオドと括弧を省略できます。
次のサンプルコードは 1 と 2 の和 3 を表示します。

    (define-cps main ^(args)
      + 1 2 ^(value)
      println value
      )

上記の関数定義 `^(args) + 1 2 ^(value) println value` は `^(args) + 1 2 . (^(value) println value)` のピリオドと括弧を省略しています。
`+ 1 2` は 1 と 2 の和 3 を求め、継続引数 `^(value) println value` の value に与え、`println value` は value の値 3 を表示します。

次の書式で Scheme 処理系の機能を利用できます。

    (lambda ^(仮引数列) 処理) 引数列

引数列の値を Scheme 処理系における仮引数列に渡し、Scheme 言語で記述された処理を実行します。
例えば、上記の `+` と `println` は次のように定義できます。

    (define-cps + ^(x y)
      (lambda (a b)(+ a b)) x y)

    (define-cps println ^(x)
      (lambda (a)(display a)(newline)) x ^(d)( ))

## Requirement

* Mac OS X  
OS X 10.9.5 で動作を確認しています．
他のバージョンやLinuxでも若干の修正によって動作すると思います．

* Scheme  
Chez (Ver. 9.4), Chicken (Ver. 4.10.0), Gambit (Ver. 4.8.7), Gauche (Ver. 0.9.5), Guile (Ver. 2.2.0)で動作を確認しています。
他のバージョンや他のScheme処理系でも、若干の修正によって動作すると思います．

サンプルコード min-div.sch の場合、インタプリタ方式ではGauche、コンパイラ方式ではGambitが最速でした。
ただし、これらが一般のコードについても最速であることを保証するものではありません。
例えば、min-div.sch は使用する記憶領域が少ないので、より大きな記憶領域を使用するアプリケーションの場合、ガーベジコレクションの性能によって順位が逆転する可能性があります。

## Installation

次のコマンドを実行してください。

    $ git clone https://github.com/shima3/sch-script

## Usage

カレントディレクトリを sch-script に変更して以下のコマンドを実行してください。

インタプリタによるスクリプトの実行

    書式$ 処理系/interpret.sh sch-script.scm スクリプト パラメータ・・・
    例$ gauche/interpret.sh sch-script.scm sample/min-div.sch 13

インタプリタのコンパイル

    書式$ 処理系/compile.sh sch-script.scm  
    例$ gambit/compile.sh sch-script.scm

コンパイル済みインタプリタによるスクリプトの実行

    書式$ 処理系/sch-script スクリプト パラメータ  
    例$ gambit/sch-script sample/min-div.sch 13

## Files

* sch-script.scm
  提案言語のインタプリタ
* sample/
  提案言語のサンプルコード
    * min-div.sch  
      2以上で最小の約数を表示する．
    * concurrent.sch
      並行処理のサンプル
    * actor.sch
      アクターモデルのサンプル
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

## License

[MIT](http://b4b4r07.mit-license.org)
