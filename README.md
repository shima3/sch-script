# Scheme Hat Script

継続渡しスタイルのラムダ計算とSchemeに基づく関数型スクリプト言語

## Description

ラムダ計算はチューリング完全で最も単純な計算モデルの1つであり、関数型プログラミング言語の理論的基礎となっています。
継続渡しスタイルは例外処理や多重ループからの脱出などの制御構造を表現したり、処理の最適化や並列化のためコンパイラの中間言語として利用されています。
本提案言語は関数型プログラミング言語の学習を目的とし、継続渡しスタイルのラムダ計算を簡潔に記述する記法を用いることによって、最小の文法で最大の表現力を目指しています。
このminimalismの設計方針、および、継続渡しスタイルが可能である点はSchemeと共通です。
ただし、Schemeでは直接スタイルを基本とし、必要に応じて継続を取り出すのに対し、提案言語では継続渡しスタイルを基本とし、継続の引数を省略した形として直接スタイル風に見せます。

## Features

* ラムダ計算  
チャーチ数、不動点コンビネータ、部分適用などラムダ計算を忠実に実行できます。

* 継続渡しスタイル  
順次処理、選択処理、反復処理などの基本的な制御構造から、複数の戻り値、例外処理、多重ループからの脱出、さらに高度な制御構造までプログラマが関数として定義することが可能です。

* 外部関数呼出し  
速度が要求される演算や入出力のため、Schemeの処理系が持つ関数を呼び出すことが可能です。

## Language

関数定義

    (define-cps 関数 ^(仮引数 ・・・) 処理)  

関数適用

    関数 実引数 ・・・ ^(変数 ・・・)  

Scheme機能呼び出し

    (lambda ^(仮引数) 処理)

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

## Usage

インタプリタによるスクリプトの実行

    書式$ 処理系/run.sh sch-script.scm スクリプト パラメータ  
    例$ gauche/run.sh sch-script.scm min-div.sch 13

インタプリタのコンパイル

    書式$ 処理系/compile.sh sch-script.scm  
    例$ gambit/compile.sh sch-script.scm

コンパイル済みインタプリタによるスクリプトの実行

    書式$ 処理系/sch-script スクリプト パラメータ  
    例$ gambit/sch-script min-div.sch 13

## Installation

    $ git clone https://github.com/shima3/sch-script

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

## License

[MIT](http://b4b4r07.mit-license.org)
