## POSIX原理主義 ＋ ときどき独自拡張機能

本レシピはシバンを`#!/bin/sh`に設定することを想定している。つまり`bash`などを極力使わないレシピを紹介している。ただ、用途によってはPOSIXを気にする必要がない場合も多々あると思われるので、時々`bash`特有あるいはGNU拡張された機能の紹介もしている。

### 基本的な作業

#### Recipe 1.1 C言語の様な`for`ループ
CやAWKの様に、開始番号、終了番号、増分を指定して`for`ループを回すことはできない。shellの`for`文はperlでいう`foreach`文に相当する。しょうがないので、素直に`while`文を使う。以下は、初期番号10、終了番号30、増分5の例を示す。
```shell
i=10
while [ $i -le 30 ] do;
    print $i
    $i=`expr $i + 5`　# その他、``の代わりに$()にする方法や$(($i+5))と書く方法もある。
done
```

#### Recipe1.2 続・C言語の様な`for`ループ
`while`文が嫌でどうしても`for`文を使いたい猛者は、以下の様にすれば"らしく"はできる。汚いけど。。初期番号10、終了番号30、増分1の場合をご覧あれ。
1. `yes`+`head`+`tail`コマンドを使う
```shell
to_val=`expr 30 - 10 + 1`
for i in `yes ""|cat -n|head -30|tail -$to_val`; do
    echo $i
done
```
もちろん上の例なら、よりシンプルに`seq`で対応可能。
```shell
for i in `seq 10 30`; do
    echo $i
done
```
2. `yes`+`head`+`awk`コマンドを使う
ここでは初期番号10、終了番号30、増分5の例を紹介する。
```shell
for i in `yes ""|cat -n|head -30|awk 'NR>=10&&NR%5==0{print}'`; do
    echo $i
done
```

#### Recipe1.3 セキュリティ・ホールを防ぐ文字列評価
`if`文を使って直感的に文字列評価すると、稀にエラーを返されることがある。不測の事態を回避するにはターゲット文字列の前に任意の英数字を付与すればよい。以下は第一引数がshellかどうかを評価する例。
```shell
if [ "_$1" = "_shell" ]; then
    echo "You're a shell aficionado !"
fi
```
上のスニペットのアンダースコア`_`を消去して、ターミナルで`./test.sh "!"`と実行すると、OSによりエラーを返されることがある。この様な誤動作は最悪の場合、セキュリティ・ホールを誘発する恐れがあるので注意。

#### Recipe1.4 インタラクティブな入力受け付け
コマンド引数ではなく標準入力から情報を受ける対話的インタフェースを作るには、`while`文と`read`の組み合わせを用いればよい。入力が適切でない場合に`while`文から抜け出せない様にする。`while`文と`read`のコンビネーションんは定石。
* 数字を選択する場合
```shell
check=""
while [ -z "$check" ]; do
    echo "Enter your cat's name"
    echo "   1) p-man"
    echo "   2) ushinosuke"
    echo "   3) komegoro"
    read check
    case $check in
        1)
            echo "DEBUNESU !"
            ;;
        2)
            echo "Hiyokko-taiyo"
            ;;
        3)
            echo "He's Torajiro"
            ;;
        *)
            echo "**** Bad choice !"
            printf '¥007'
            check=""
            ;;
    esac
done
```
* 「はい」または「いいえ」を選択する場合
```shell
check=""
while [ -z "$check" ]; do
    echo -n "Do you like bretzel (Y/N) ? "
    read check
    case $check in
        [Yy]*)
            check="YES"
            ;;
        [Nn]*)
            check="NO"
            ;;
        *)
            echo '*** Answer either "Yes" or "No" !'
            printf '¥007'
            check=""
            ;;
    esac
done
```
* 一時停止
```shell
check=""
echo -n "Press the return key when ready : "
read check
```
Mac（FreeBSD）では、Bourne Shellは`echo`に`-n`オプションをサポートしていないことに注意。

#### Recipe1.5 標準エラー出力の扱い方
標準エラー出力は`2>`でリダイレクトできる。標準エラーの出力先`2`に標準出力の出力先`1`をコピーするには,

`2>&1`とすればよい。

* 標準エラー出力をビットバケツに捨てる場合（tmp.txtが存在しない状況を想定）
`rm tmp.txt 2>/dev/null`
* 標準エラー出力を、次のコマンドにパイプで渡す場合
`rm tmp.txt 2>&1|awk 'sub(/No/,"NO")'`
* 標準出力も標準エラー出力の結果もビットバケツに捨てる場合
`rm tmp.txt >/dev/null 2>&1`

#### Recipe1.6 標準エラー出力にメッセージを送る
特殊ファイルの`/dev/stderr`にリダイレクトすればよい。
`echo "*** ERROR ***" >/dev/stderr`

---

### 変数操作

#### Recipe2.0 変数の初期設定
以下の４つの設定方法を使うと、変数が定義済みか未定義かで振る舞いが変わる。
1. `=`による変数の設定
`${variable:=value}` これまで未使用かヌル値であればvalueを使う。
`${variable=value}` これまで未使用であればvalueを使う。ヌル値が入っていればヌル値を使う。
```shell
echo ${ABC:=xyz}   # xyz
echo $ABC          # xyz
echo ${ABC:=abc}   # xyz
ABC=""
echo ${ABC=123}    # null
echo ${ABC:=123}   # 123
```
2. `-`による変数の設定
`${variable:-value}` 変数がこれまで未使用・未定義のときに値を**代入しないまま**、指定した値を返す。
```shell
echo {ABC:-xyz}    # xyz
echo $ABC          # null
echo {ABC:=abc}    # abc
echo $ABC          # abc
```
3. `?`による変数の設定
`${variable:?msg}` 変数が未使用・未定義であるか確認する。未使用・未定義の場合はmsg部分が表示される。
```shell
echo ${ABC:?"ABC is not set"}
```
4. `+`による変数の設定
`${variable:+value}`変数が定義済みのとき、値を取り替えて表示する。ただし実際の変数の値は変わらない。
```shell
echo ${ABC:+zzz}    # null
ABC=www
echo $ABC           # www
echo ${ABC:+zzz}    # zzz
echo $ABC           # www
```

#### Recipe2.1 変数のチェック
未定義の変数へのアクセスや変数のスコープ、`Fortran`でいう`parameter`属性をシェルでも適用できる。
1. 未定義の変数へのアクセス制御
`set`コマンドに`-u`オプションをつけて実行すると、未定義の変数にアクセスした際に、エラーを出して止まる。
```shell
set -u
echo $i
```
2. スコープ
シェルスクリプト内の変数は、基本すべてファイル内global変数として働く。ユーザ定義関数内で名前の衝突を防ぐためには、`local`修飾子を使って変数定義すればよい。
```shell
var="var outside f"
f () {
    local var
    var="var in f"
    echo "$var"
}

f
echo "$var"
```
3. パラメタの定義
変数をパラメタとして扱いたいとき、`readonly`修飾子を指定して定義すればよい。上書きしようとするとエラーを吐いて止まる。
```shell
readonly var=100
var=10
```

#### Recipe2.2 変数の解除（未定義化）
変数の解除（未定義化）とは、変数にヌル値を代入するのではなく、変数そのものが無かったことにする操作である。解除するには`unset`コマンドを使う。
```shell
ushinosuke=0313
declare|grep ushinosuke

unset ushinosuke
declare|grep ushinosuke
```

#### Recipe2.3 変数が未定義か判別する
変数名の後にハイフン＋メッセージをつける。例えば変数`var`が未定義かどうか確かめたいならば、`${var-UNDEF}`などとすればよい。
```shell
defined="YES"
if [ "${var-UNDEF}" = "UNDEF" ]; then
    if [ -z "$var" ]; then
        defined="NO"
    fi
fi
echo $defined
```

#### Recipe2.4 親プロセスから子プロセスへ変数を渡す
親プロセスで用いた変数を子プロセスに渡したいときは、子プロセスを起動する前に`export`コマンドを使えばよい。
* 親スクリプト
```shell
local="gorin"
global="debunesu"

export global

./child.sh

echo " local@parent   : $local"
echo " global@parent  : $global"
```
* 子スクリプト
```shell
echo "start $0"

echo " local@child  : $local"
echo " global@child : $global"

local="ushinosuke"
global="tora"

export global
echo "end $0"
```

#### Recipe2.5 子プロセスから親プロセスへ変数を渡す
`export`コマンドを使っても子プロセスから親プロセスに変数を渡すことはできない。そこで、ファイルを介して渡すようにする。`eval`コマンドを使うのもポイント。`"`や`$`を記述するときには、`¥`でエスケープする必要があることに注意。

* 親スクリプト
```shell
global1="sato"
global2="shio"

export global1
export global2

temp_file=`mktemp /tmp/ONABE_GUTSUGUTSU.XXXXXX`
export temp_file

./child.sh

for variable in `cat $temp_file`; do
    eval $variable
done

rm -f $temp_file

echo "  global1@parent : $global1"
echo "  global2@parent : $global2"
```
* 子スクリプト
```shell
echo "start $0"

echo "  global1@child : $global1"
echo "  global2@child : $global2"

global1="tamanegi"
global2="mitsuba"

if [ -f "$temp_file" ]; then
    for variable in global1 global2; do
        eval echo $variable=¥'¥$$variable¥'
    done
fi

echo "end $0"
```

#### Recipe2.6 配列を使う
bashには配列変数があるが、Bシェルにはない。だが`eval`コマンドを活用すれば、配列っぽいものを無理やり定義することができる。シェルスクリプトではさておき、一行野郎で配列を使うことは勧められないが、一応紹介しておく。
```shell
lsDay=0
eval lsDay_$lsDay=¥"Monday¥"   ; lsDay=`expr $lsDay + 1`
eval lsDay_$lsDay=¥"Tuesday¥"  ; lsDay=`expr $lsDay + 1`
eval lsDay_$lsDay=¥"Wednesday¥"; lsDay=`expr $lsDay + 1`
eval lsDay_$lsday=¥"Thursday¥" ; lsDay=`expr $lsDay + 1`
eval lsDay_$lsDay=¥"Friday¥"   ; lsDay=`expr $lsDay + 1`
eval lsDay_$lsDay=¥"Saturday¥" ; lsDay=`expr $lsDay + 1`

i=0
while [ $i -lt $lsDay ]; do
    eval echo ¥$lsDay_$i
    i=`expr $i + 1`
done
```

#### Recipe2.7 連想配列を使う
bashにも連想配列はないが、先ほどと同様に`eval`コマンドを駆使することで、連想配列もどきを作れる。ポイントはキーを定義する際に「スペース」を入れること！
```shell
hnCalorie=" "
eval hnCalorie_zarusoba=¥"300¥"; hnCalorie="${hnCalorie}zarusoba " # スペースを入れること
eval hnCalorie_doria=¥"700¥"   ; hnCalorie="${hnCalorie}doria " # スペースを入れること
eval hnCalorie_unadon=¥"650¥"  ; hnCalorie="${hnCalorie}unadon " #スペースを入れること

for key in $hnCalorie; do
    eval echo "$key : ¥$hnCalorie_$key"
done
```

---

### 数値操作

#### Recipe3.1 高度な計算
シェルだけで高度な演算を実行しようと思うこと自体が間違っているが、`expr`コマンドではあまりにも貧弱すぎる。こういうときは潔く、他の言語の力を借りる。例えば`AWK`。`print`文の引数に渡すだけで解決できるからだ。
```shell
a=7;b=-56;c=105
x="(-($b)+sqrt(($b)^2-4*($a)*($c)))/(2*($a))"
awk 'BEGIN{print $x}'
```

#### Recipe3.2 四捨五入
`printf`関数の丸め機能は信用してはいけない。この様な変な挙動を見せることがある。
```shell
printf "%1.0f¥n" 0.5  # 結果は0
```
ちゃんと0.5を足して`int`関数で整数化する。

```shell
value=1.3
rounded_value=`awk "BEGIN{print int($value+0.5)}"` # ダブルクォート！
echo "The answer is ¥"$rounded_value¥"."
```
上のスクリプトで、`BEGIN`ブロックがダブルクォートで囲まれていることに注意。ブロック内でシェル変数が使われているため、ダブルクォートにしておかないと展開されない。

#### Recipe3.3 乱数の生成
Linux環境によって注意すべき点がある。例として、サイコロを取り上げる。
* BSD系でない場合
1. `AWK`の`srand`関数を使ってシードを設定する。
```shell
awk 'BEGIN{srand(); print int(rand()*6)+1}'
```
2. 擬似デバイス`/dev/urandom`からバイナリを取り出し、数値化する。まず`od`コマンドで長い10進表示にして、`head`で一行だけ取り出す。その後`tr`で数字のみを出力し、`cut`することで最初の5文字を抽出する。最後に結果を`AWK`にかける。
```shell
cat /dev/urandom|od -DA n|head -1|tr -dc 0-9|cut -c -5|awk '$0=int($0*6/10^5)+1'
```
* BSD系の場合
`AWK`の`srand`関数が貧弱すぎて使い物にならない。シードを変えているつもりでも同じ値が出力されてしまう。したがって、BSD系でサポートされている`jot`コマンドを使うとよい。
```shell
jot -r 1 1 6
```

#### Recipe3.4 10進数から8進数・16進数への変換および逆変換
`printf`コマンドを使えばすべてが解決する。`printf`万歳。
* 16進 --> 10進
```shell
hex=0x41
printf "%d¥n" $hex
```
* 8進 -> 10進
```shell
oct=0123
printf "%d¥n" $oct
```
* 10進 -> 16進
```shell
dec=65
printf "0x%x¥n" $dec
# printf "0x%X¥n" $dec
```
* 8進 -> 10進
```shell
dec=65
printf "0%o¥n" $dec
```

#### Recie3.5 10進数から2進数への変換および逆変換
`printf`コマンドには2進数がサポートされていない。したがって、代わりに`bc`コマンドを使う。`ibase`（入力）と`obase`（出力）に基数を指定することで、あらゆる基数間の変換ができる。

* 2進 -> 10進
```shell
bin=1000001
dec=`echo "ibase=2;$bin"|bc`
```
* 10進 -> 2進
```shell
dec=65
bin=`echo "obase=2;$dec"|bc`
```

#### Recipe3.6 数字として扱える文字列かどうか判定する
引数が10進数、16進数、8進数、2進数であるかどうかを確認するには、以下の様にすればよい。
* 10進数かどうかの判定
```shell
if [ -z "`echo "$1"|grep '^[0-9]¥+$'`" ]; then
    echo "Invalid number!"
    exit 1
fi
```
* 16進数かどうかの判定
```shell
if [ -z "`echo "$1"|grep '^0x[0-9a-fA-F]¥+$'`" ]; then
    echo "Invalid number!"
    exit 1
fi
```
* 8進数かどうかの判定
```shell
if [ -z "`echo "$1"|grep '^0[1-7]*$'`" ]; then
    echo "Invalid number!"
    exit 1
fi
```
* 2進数かどうかの判定
```shell
if [ -z "`echo "$1"|grep '^[01]¥+$'`" ]; then
    echo "Invalid number!"
    exit 1
fi
```

---

### 文字列操作

#### Recope4.1 文字列の長さを調べる
変数展開を活用すると、とても簡単に文字列長を取得できる。
```shell
string="文字列"
echo ${#string}
```
ただし、ロケールによって返り値が文字数なのかバイト数なのか変わることに注意。文字コードがUTF-8の場合は文字数、ASCIIの場合はバイト数を返す。
```shell
string="文字列"
LANG=ja_JP.UTF-8; echo ${#string}　# 返り値は3
LANG=C; echo ${#string}　# 返り値は9（3バイトが3字分）
```

#### Recipe4.2 文字列の一部を抽出する
`cut`で頑張る。文字数をカウントする場合は`-c`オプション、バイト数のカウントは`-b`オプションを使う。
```shell
string="KabayakiUnagiSanshou"
left_word=`echo "$string"|cut -c -8`
middle_word=`echo "$string"|cut -c 9-13`
right_word=$(echo "$string"|cut -c `expr ${#string} - 7 + 1` -)
```

#### Recipe4.3 大文字 <=> 小文字変換
定番の`tr`コマンドを使う方法、変数展開を活用する方法、そしてAWKer流を紹介する。
* `tr`コマンドを使う場合
```shell
mycat="Debunesu"
echo "$mycat"|tr 'a-z' 'A-Z'　# 大文字化
echo "$mycat"|tr 'A-Z' 'a-z'　# 小文字化
```
* 変数展開を使う場合（注：`bash`バージョン4以降）
```shell
mycat="Debunesu"
echo ${mycat^^}　# 大文字化
echo ${mycat,,}　# 小文字化
```
* AWKer流
```shell
mycat="Debunesu"
echo "$mycat"|awk '$0=toupper($0)'　# 大文字化
echo "$mycat"|awk '$0=tolower($0)'　# 小文字化
```

#### Recipe4.4 ASCIIコード <=> キャラクタ変換