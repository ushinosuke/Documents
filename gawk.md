## AWK

### 重要コマンド
* 時刻・時間の取得
	* UNIX時間
		1. `awk 'BEGIN{print srand()+srand()}'`
		2. `awk 'BEGIN{print systime()}'`
	* 時刻
		1. `awk 'BEGIN{"date +%s"|getline;print}'`
		2. `awk 'BEGIN{print strftime("%Y/%m/%d %H:%M:%S", systime())}'`

---


### 苦手コマンド
* 文字列抽出
	* index関数の活用
		`echo {a..e}|tr -d ' '|awk '$0=substr($0,index($0,"b"))'`
	* match関数の活用
		`echo {a..e}|tr -d ' '|awk 'match($0,/b.*/){print substr($0,RSTART,RLENGTH)}'`
* 文字列置換
	1. `echo {a..e}|tr -d ' '|awk 'sub(/./,"A")'`
	2. `echo {a..e}|tr -d ' '|awk 'gsub(/./,"A")'`
	3. `echo 'sumomomomonouti'|tr -d ' '|awk '{print gensub(/m/,"M","g",$0);print}'` #gawk
	4. 後方参照（back reference）
		`echo 'sumomomomomonouti'|awk '{print gensub(/(mo)(no)/,"¥¥1¥"¥¥2¥"","g",$0)}'` #gawk
* 双方向パイプ
