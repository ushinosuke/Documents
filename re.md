## 正規表現

* 正規表現は、"文字パターンや文字**シーケンス**を表す式"
* 正規表現だけで全てをカバーしようとするのは必ずしも現実的とは言えない。`grep`を使うときは特にそうだ。しかし、`sed`で正規表現を使って置換する場合は「完璧な」正規表現を指定するように十分注意する必要がある。
* AWKの正規表現は注意が必要！
* 拡張正規表現： `grep`に`-E`オプションをつける、あるいは`egrep`を使う
	* 選択演算子　*e.g.* `UNIX|LINUX`
	* グループ化演算子：　優先順位をつける
		1. LaboratiresとLabsを含む文字列とマッチ
		`cat tmp.txt|grep -E 'Lab(oratorie)?s'`
		2. companyとcompaniesを含む文字列とマッチ
		`cat tmp.txt|grep -E 'compan(y|ies)'`
* 正規表現は、**最長の文字列**にマッチしようとする。

---

#### あらゆる文字列
* クォーテーションマークに囲まれた任意の文字列
	`cat tmp.txt|grep '".*"'`
#### 行頭に空白を含む行
* メタキャラクタ`*`を使う場合
	1. `cat tmp.txt|grep '^  *.*'`
	2. `cat tmp.txt|grep -E '(^ ) *.*'`
	3. `cat tmp.txt|grep egrep '(^ ) *.*'`
* メタキャラクタ`+`を使う場合
	1. `cat tmp.txt|grep '^ +'`
#### ファイル中の空行をカウント
* 正規表現を使う場合
	`cat tmp.txt|grep '^$' -c`
* 空白の入っている空行も検知したい
	`cat tmp.txt|grep '^ *$' -c`
*　AWKerならこうする（あらゆる空行を検知）
	`cat tmp.txt|awk '!NF'|wc -l`
#### 行全体にマッチさせたい：　`sed`で使うことあり
`cat tmp.txt|sed 's/^.*$'/debunesu/`
#### 文字の繰り返し回数
* 日本の郵便何号
`[0-9]¥{3¥}-[0-9]¥{4¥}`
#### HTMLインラインコードの抽出
`cat tmp.html|grep '<[^>]*>'`

