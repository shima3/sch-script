# Hat Interpreter

An Interpreter of The Hat Programming Language

Hatプログラミング言語のインタプリタ

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

    (include "util.sch")
    (defineCPS main ^(args)
      print("Hello, World!\n"))

include は次の書式で別のファイルを読み込みます。

    (include "ファイル名")

util.sch には入出力、数値計算、数列、文字列、リストなどの処理が定義されています。

defineCPS は次の書式で関数を定義します。

    (defineCPS 関数名 関数定義)

関数名は１つの変数で、変数の厳密な書式は使用する Scheme 処理系に依存しますが、主に英数字からなる文字列です。
関数定義は次の書式で基本的な計算を示します。

    ^(仮引数列 . 継続仮引数) 関数 引数列 . 継続引数

仮引数列は変数の列、継続仮引数は１つの変数です。
関数と継続引数は１つの項、引数列は項の列です。

複数の変数は空白で区切ります。
項は変数または括弧で囲んだ関数定義です。
継続仮引数または継続引数の前のピリオドの前後には空白が必要です。

上記のサンプルコードの場合、関数 main が仮引数 args をとり、関数 print を呼び出し、その引数が ("Hello, World!\n") であることを示します。
関数 main は、プログラムを実行したとき、最初に呼び出される関数です。

仮引数が必要ない場合、次のように記述します。

    ^ 継続仮引数 関数 引数列 . 継続引数

継続仮引数が必要ない場合、次のように記述します。

    ^( ) 関数 引数列 . 継続引数

引数列が必要ない場合、次のように記述します。

    ^(仮引数列 . 継続仮引数) 関数 . 継続引数

継続引数が継続仮引数と同じ場合、継続引数を次のように省略できます。

    ^(仮引数列 . 継続仮引数) 関数 引数列

上記のサンプルコードの関数定義 `^(args) print("Hello, World!\n")` は `^(args . c) println "Hello, World!" . c` の継続仮引数と継続引数を省略しています。
関数 main を呼び出すとき、戻り先が継続仮引数 c に渡され、`println "Hello, World!"` を実行した後、c を呼び出します。

継続引数として関数定義を渡す場合、ピリオドと括弧を省略できます。
次のサンプルコードは 1 と 2 の和 3 を表示します。

    (defineCPS main ^(args)
      + 1 2 ^(value)
      print(value))

上記の関数定義 `^(args) + 1 2 ^(value) println value` は `^(args) + 1 2 . (^(value) print(value))` のピリオドと括弧を省略しています。
`+ 1 2` は 1 と 2 の和 3 を求め、継続引数 `^(value) print(value)` の value に与え、`print(value)` は value の値 3 を表示します。

次の書式で Scheme 処理系の機能を利用できます。

    (lambda(仮引数列) 処理) 引数列

引数列の値を Scheme 処理系における仮引数列に渡し、Scheme 言語で記述された処理を実行します。
例えば、上記の `+` と `print` は次のように定義できます。

    (defineCPS + ^($a $b)
      (lambda(a b)
        (+ a b)
      ) $a $b)

    (defineCPS print ^($list . $return)
      (lambda(list)
        (display (string-concatenate (map x->string list)))
      ) $list ^($dummy)
      $return)

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

    書式$ 処理系/interpret.sh src/hat.scm スクリプト パラメータ・・・
    例$ gauche/interpret.sh src/hat.scm sample/min-div.sch 13

インタプリタのコンパイル

    書式$ 処理系/compile.sh src/hat.scm  
    例$ gambit/compile.sh src/hat.scm

コンパイル済みインタプリタによるスクリプトの実行

    書式$ 処理系/sch-script スクリプト パラメータ  
    例$ gambit/sch-script examples/min-div.sch 13

## Test

$ test/all.sh src/hat.scm diff interpret gauche

## Files

* hat.scm
  Hat言語のインタプリタ
* examples/
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

ここに掲載した著作物の利用に関する注意：
本著作物の著作権は日本ソフトウェア科学会に帰属します。
本著作物は著作権者である日本ソフトウェア科学会の許可のもとに掲載するものです。
ご利用に当たっては「著作権法」に従うことをお願いいたします。

Notice for the use of this material: 
The copyright of this material is retained by the Japan Society for Software Science and Technology (JSSST). 
This material is published on this web site with the agreement of the JSSST. 
Please be complied with Copyright Law of Japan if any users wish to reproduce, make derivative work, distribute or make
available to the public any part or whole thereof. 

[MIT](http://b4b4r07.mit-license.org)
