## sed

### 基本的な使い方とオプション
* 複数の命令を指定する方法
	1. 命令を`;`で区切る
		`cat list|sed 's/ MA/, Masachusetts/;s/ PA/, Pennsylvania/'`
	2. 各命令の前に`-e`オプションをつける
		`cat list|sed -e 's/ MA/, Massachusetts/' -e 's/ PA/, Pennsylvania/'`
	3. マルチライン入力する　注）cshでは使えない 
		```shell
		cat list|sed '
		    s/ MA/, Massachusetts/
		    s/ PA/, Pennsylvania/
		    s/ CA/, California/
		'
		```
	4. 処理をファイルに書いて読み込む
		`cat list|sed -f sedsrc`
		ファイルの中身はこちら。
		```shell
		cat sedsrc
		> s/ MA/, Massachusetts/
		> s/ PA/, Pennsylvania/
		> s/ CA/, California/
		> s/ VA/, Virginia/
		> s/ OK/, Oklahoma/
		```
* 入力行の自動出力を制御する
	1. 標準出力をしない
	`cat list|sed -n 's/ MA/, Massachusetts/'`
	2. 変更箇所のみ標準出力する
	`cat list|sed -n 's/ MA/, Massachusetts/p'`

---

### 実行例
* Zipコードの3桁目と4桁目との間にハイフンを入れる
	1. `cat zipcode|sed 's/.../&-/'`
	2. `cat zipcode|sed -E 's/.{3}/&-/'`
	3. `cat zipcode|sed 's/¥(...¥)¥(....¥)/¥1-¥2/'`
* 範囲指定して置換する
  * 2行目だけを置換
	`echo {a..e}|xargs -n 1|sed '2s/./?/'`
	* 3行目から最終行までを置換
		1. `echo {a..e}|xargs -n 1|sed '3,$s/./?/'`
		2. `echo {a..e}|xargs -n 1|sed '/c/,/e/s/./?/'`
		3. `echo {a..e}|xargs -n 1|sed '/a/,/b/!s/./?/'`
* 範囲指定して出力する
	* 2行目だけを標準出力
		1. `echo {a..e}|xargs -n 1|sed -n '2p'`
		2. `echo {a..e}|xargs -n 1|awk 'NR==2'`
	* 2行目から4行目をし標準出力
		1. `echo {a..e}|xargs -n 1|sed -n '2,4p'`
		2. `echo {a..e}|xargs -n 1|awk 'NR==2,NR==4'　# AWKer`
		3. `echo {a..e}|xargs -n 1|awk 'NR>=2&&NR<=4' # AWKer`
* 範囲指定して行を消去する
	* 2行目を消去
	1. `echo {a..e}|xargs -n 1|sed '2d'`
	2. `echo {a..e}|xargs -n 1|awk 'NR!=2'`
	* 最終行を消去
	`echo {a..e}|xargs -n 1|sed '$d'`
* ファイルの先頭行に追記する
```shell
cat tmp.txt|sed '1s/^/debunesu¥n/'
```

