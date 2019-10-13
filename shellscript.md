## POSIX原理主義 ＆ ときどき独自拡張機能

本レシピはシバンを`#!/bin/sh`に設定することを想定している。つまり`bash`などを極力使わないレシピを紹介している。ただ、用途によってはPOSIXを気にする必要がない場合も多々あるので、時々`bash`特有あるいはGNU拡張された機能の紹介もしている。もしもPOSIX原理主義を貫くのならば、今後は以下に挙げる機能とは決別する覚悟を持たねばならない。
* ブレース展開
* プロセス置換
* PIPESTATUS

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

#### Recipe1.3 続続・C言語の様な`for`ループ
本レシピは邪道（？）ゆえ注意。堂々と`bash`を使う。開き直ってもよければこうすればよい。
```shell
#!/bin/bash

for ((i=0;i<=10;i++)); do
    echo $i
done
```

#### Recipe1.4 セキュリティ・ホールを防ぐ文字列評価
`if`文を使って直感的に文字列評価すると、稀にエラーを返されることがある。不測の事態を回避するにはターゲット文字列の前に任意の英数字を付与すればよい。以下は第一引数がshellかどうかを評価する例。
```shell
if [ "_$1" = "_shell" ]; then
    echo "You're a shell aficionado !"
fi
```
上のスニペットのアンダースコア`_`を消去して、ターミナルで`./test.sh "!"`と実行すると、OSによりエラーを返されることがある。この様な誤動作は最悪の場合、セキュリティ・ホールを誘発する恐れがあるので注意。

#### Recipe1.5 インタラクティブな入力受け付け
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

#### Recipe1.6 標準エラー出力の扱い方
標準エラー出力は`2>`でリダイレクトできる。標準エラーの出力先`2`に標準出力の出力先`1`をコピーするには,

`2>&1`とすればよい。

* 標準エラー出力をビットバケツに捨てる場合（tmp.txtが存在しない状況を想定）
`rm tmp.txt 2>/dev/null`
* 標準エラー出力を、次のコマンドにパイプで渡す場合
`rm tmp.txt 2>&1|awk 'sub(/No/,"NO")'`
* 標準出力も標準エラー出力の結果もビットバケツに捨てる場合
`rm tmp.txt >/dev/null 2>&1`

#### Recipe1.7 標準エラー出力にメッセージを送る
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
* ASCIIコード-キャラクタ変換
まずはASCIIコードをスラッシュ付き8進数（3桁）で表現する。それを`printf`コマンドに渡せば解決。ただし改行コード`LF`が自動的に取り去られてしまう問題を回避するために、任意の1文字をつけてすぐに消去するプロセスが入る。
```shell
ascii_code="$1"
bsla_oct=`printf "¥134%03o" $ascii_code`　# ¥134はスラッシュ
char=`printf "${bsla_oct}_"`
char="${char%_}"
echo "$char"
```
* キャラクタ-ASCIIコード変換
`od`コマンドでダンプすればよい。`uC`オプションにより、1バイト整数（符号なし）とみなして表示する。アドレス部を無視するために`AWK`で該当部のみを抽出している。
```shell
char="$1"
ascii_code=`echo -n "$char"|od -t uC|awk 'NR==1{print $2}'`
[ -z "$ascii_code" ] && ascii_code=0
echo "$ascii_code"
```
* `AWK`の`printf`関数を使う方法
```shell
echo 34 | awk '{printf"%c¥n",$1}'
```

#### Recipe4.5 正規表現でマッチした文字列の抽出
シェルスクリプトでは正規表現が使えることは紛れもない事実である。しかし、マッチした文字列を抽出することに関しては、あまり得意としていない。`AWK`、`sed`、`grep`を使う方法があるが、いずれも弱点を持っている。`AWK`は便利な組み込み関数があるが、正規表現そのものが貧弱である。`sed`の正規表現は`AWK`よりも充実している。しかし、複数行に渡ってマッチングする場合は注意を要する。最後に`grep`についてだが、`-o`オプションで全てを解決できると思うかもしれない。しかし、`-o`オプションが使えるのは`GNU grep`でかつバージョンが2.5以降という盲点がある。
1. `AWK`：組み込み関数を使う。
```shell
echo "STRING"|awk 'match($0,/PATTERN/){print substr($0,RSTART,RLENGTH)}'
```
2. `sed`：後方参照を使う。
```shell
echo "STRING"|sed 's/.*¥(PATTERN¥).*/¥1/'
```
3. `grep`：`-o`オプションを使う。
```shell
echo "STRING"|grep -o 'PATTERN'
```

#### Recipe4.6 特定文字のトリミング
シェル変数は`#`と`%`を駆使すれば、それぞれ左端・右端からトリミングができる。より具体的には`${var#パターン}`で`var`の左端から、`${var%パターン}`で`var`の右端からパターンにマッチした場合に限り、トリミングが行われる。
```shell
string="---debunesu-gorin-uchan---"
trimming_chr="-"

while [ "_$string" != "_${string#[$trimming_chr]}" ]; do
    string=${string#[$trimming_chr]}
done
while [ "_$string" != "_${string%[$trimming_chr]}" ]; do
    string=${string%[$trimming_chr]}
done

echo "$string"
```

#### Recipe4.7 パス名中のファイル名・ディレクトリ名を抽出する
シェル変数のトリミング機能を利用する方法とコマンドを使う方法がある。
1. トリミング機能の利用
前項で`#`は左側からのマッチングを行うことを紹介した。さらに#をもう一つ加えて`##`とすると、最大マッチングを行う。パターンに`*/`を指定すれば目的が達せられる。
```shell
filepath="/food/Nihon/yoshoku/hayashirice.txt"

filename="${filepath##*/}"
dirpath="${filepath%/*}"
```
2. コマンドの利用
`basename`コマンドと`dirname`コマンドを使えばすぐにできる。
```shell
filename=`basename "$filepath"`
dirpath=`dirname "$filepath"`
```

#### Recipe4.8 ランダムな文字列の生成
既に登場した乱数の生成やASCII<=>キャラクタ変換のテクニックを活用すれば、ランダムな文字列を生成できる。しかし、「あるものは利用する」というシェルスクリプトの精神に基づき、ここでは`mktemp`コマンドを活用した」レシピを以下に紹介する。
```shell
RAND=`mktemp /tmp/temp.XXXXXX`
if [ $? -eq 0 ]; then
    rm $RAND ; RAND=${RAND#/tmp/temp.}
fi
```

---

### フィールド・ライン処理

#### Recipe5.2 最後からn番目のフィールドを得る
以下は最後から2番目のフィールドの値（d）を得る方法。勿論`AWK`を使う。シェルスクリプトと`AWK`を組み合わせる時には、`AWK`のパターンをシングルクォート`'`ではなくダブルクォート`"`で表すこと、そして`$`の前にバックスラッシュ`¥`を「2つ」つけることがポイント。
```shell
d=`echo {a..e} | awk "{num=NF+1-2;print ¥¥$num}"`
```
バックスラッシュ`¥`が2つ必要なのは、バッククォートで囲む場合のみ。つまり、`$()`を使うときは次の様になる。
```shell
d=$(echo {a..e} | awk "{num=NF+1-2;print ¥$num}")
```
余談ながら、エレガントなAWKerはこんな書き方をしない。次の一行野郎をとくと見よ。
```shell
d=`echo {a..e} | awk "¥¥$0=¥¥$(NF+1-2)"` 
```
あるいは
```shell
d=$(echo {a..e} | awk "¥$0=¥$(NF+1-2)")
```

#### Recipe5.3 特定の行を出力する
`AWK`一択。範囲指定演算子`,`を活用する。
```shell
### Help Messenger ####################################

#                                                     #

# Usage : helpmsgr.sh [ -h | --help ]                 #

# (Do nothing when no option or invalid option given) #

#                                                     #

#######################################################

if [ ¥( "_$1" = "_-h" ¥) -o ¥( "_$1" = "_--help" ¥) ]; then
    awk "/^### /,/^####/{print ¥$0}" $0
fi
```

#### Recipe5.4 1行ごとに処理をする
例として、全プロセスのプロセスIDとコマンドを列挙するスクリプトを考える。いくつかの方法を記すが、それぞれ一長一短がある。
1. その１
```shell
number=0
ps ax -o "pid ucomm" | while read line; do
    pid=`echo "$line" | awk "{print ¥¥$1}"`
    [ -n "`echo "$pid" | grep "[^0-9]"`" ] && continue
    number=`expr $number + 1`
    command=`echo "$line" | awk "{print ¥¥$2}"`
    
    printf "#%-3d : pid=%d is %s¥n" $number $pid "$command"
done

echo "The number of processes is ${number}."  # 失敗する。while文中は子プロセスの様なもの！
```
このスクリプトでは、プロセス数を正しくカウントできない。原因は`while`文におけるカウンタの扱われ方だ。`while`文の中は「子プロセス」の様な扱いになる。従って、**`while`節の外から中には渡せても、中から外へは変数を渡すことができない！**
2. その２：　テンポラリ・ファイルを利用する
```shell
number=0

temp_file=`mktemp /tmp/proclist.XXXXXX`
ps ax -o "pid ucomm" > $temp_file
exec 3<&0 < $temp_file
while read line; do　　　　　　　　　　　　　　　　　　　　　　　　　# ここでパイプを使っていない！
    pid=`echo "$line" | awk "{print ¥¥$1}"`
    [ -n "`echo "$line" | grep "[^0-9]"`" ] && continue
    number=`expr $number + 1`
    command=`echo "$line" | awk "{print ¥¥$2}"`
    printf "#%-3d : pid=%d is %s¥n" $number $pid "$command"
done

exec 0<&3 3<&-
[ -f "$temp_file" ] && rm -f $temp_file

echo "The number of processes is ${number}."
```
上で`while`文の中は「子プロセス」の様に振る舞うと書いたが、**パイプ`|`を使わない場合は`while`節の外に変数を出すことができる。** パイプを使わない様にするために、このレシピでは`exec`コマンドを駆使してファイル・ポートをコピー、改造している。ポートは通常、3番から9番までは未使用状態で存在している。本レシピの欠点は、テンポラリ・ファイルを作れない環境には適用できないことにある。

3. その３：　環境変数`IFS`を改変して`for`文を利用する
`for`文で行単位の処理ができない理由は、同じ行中に **タブ** や **スペース** があると`for`文がそこで切ってしまうことにある。区切りの基準が環境変数`IFS`（Input Field Separator）として設定されている。デフォルトでは`IFS`は**タブ・スペース・改行**となっている。従って以下のコマンドを実行すると、期待通りの結果を得ることができない。
```shell
> for line in `echo -e "aaa bbb ccc¥nddd eee fff"`; do echo $line; done
> aaa
> bbb
> ccc
> ddd
> eee
> fff
```

そこで`for`文を使う場合は、`IFS`を再定義すればよい。上の例の場合、次の様に設定する。
```shell
> IFS_BACKUP=$IFS
> IFS=`printf '¥012_'` ; echo ${IFS%_}　　　# IFSに改行を設定

> for line in `echo -e "aaa bbb ccc¥nddd eee fff"`; do echo $line; done
> aaa bbb ccc
> ddd eee fff

> IFS=$IFS_BACKUP
> unset IFS_BACKUP　　　　　　　　　　　　　　　# IFS_BACKUPを未定義化
```
以上の内容を踏まえると、３つ目の処方箋は以下の様に書ける。
```shell
IFS_BACKUP=$IFS
IFS=`printf '¥012_'` ; IFS=${IFS%_}

number=0
for line in `ps ax "pid ucomm"`
do
    pid=`echo "$line" | awk "{print ¥¥$1}"`
    [ -n "`echo "$pid" | grep "[^0-9]"`" ] && continue
    number=`expr $number + 1`
    command=`echo "$line" | awk "{print ¥¥$2}"`
    
    printf "#%-3d : pid=%d is %s¥n" $number $pid "$command"
done

IFS=$IFS_BACKUP
unset IFS_BACKUP

echo "The number of processes is ${number}."
```
4. その４：　空白・タブを無理やり置換することで`for`文を使う
環境変数`IFS`のデフォルト値が空白・タブ・改行であることが、`for`文ではうまく行かない理由であった。従って、空白・タブを差し障りない任意の文字に置換してやればよいだろう。ASCIIコードの0番から31番に割り当てられているコントロールコードは、通常はテキスト・ファイルには用いられない。これを利用して、以下のレシピができる。
```shell
number=0
for line in `ps ax -o "pid ucomm"    | &
             sed -e 's/¥(.*¥)/¥1_/'  | &
             tr ' ¥t' '¥006¥025'`
do
    line=`echo "$line" | tr '¥006¥025' ' ¥t'`
    line=${line%_}
    pid=`echo "$line" | awk "{print ¥¥1}"`
    [ -n "`echo $pid | grep "[^0-9]"`" ] && continue
    number=`expr $number + 1`
    command=`echo "$line" | awk "{print ¥¥$2}"`
    
    printf "#%-3d : pid=%d is %s¥n" $number $pid "$command"
done

echo "The number of processes is ${number}."
```
ここで、各行の末尾にアンダー・スコアを入れているのは、空行対策である。

#### Recipe.5.6 ソートする
常套手段である`sort`コマンドを使う。`sort`は「アルファベット順に昇順・スペース区切り」がデフォルトの設定になっている。変更するためには`-t`（フィールド区切り文字）や`-k`オプション（キー）を使う。次の様なソートを考える。
1. 第2フィールドを、アルファベット順に、昇順
2. 第1フィールドを、アルファベット順に、降順
3. 第3フィールドを、数値順に、降順
4. 区切り文字はカンマ
```shell
echo -e 'aa,aa,2¥naa,aa,3¥naa,ab,3¥nab,aa,2¥naa,aa,10' | 
sort -t "," -k2,2 -k1r,1 -k3nr,3
```

#### Recipe5.7 CSV形式データ処理