## シェルレシピ

### 基本的な作業

#### Recipe 1.1 C言語の様な`for`ループ
CやAWKの様に、開始番号、終了番号、増分を指定して`for`ループを回すことはできない。shellの`for`文はperlでいう`foreach`文に相当する。しょうがないので、素直に`while`文を使う。以下は、初期番号10、終了番号30、増分5の例を示す。
```shell
i=10
while [$i -le 30] do;
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
#### Recipe1.3 