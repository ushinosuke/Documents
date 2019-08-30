## AWK

### 重要コマンド
* 表示範囲の指定（行）
	* 先頭行から空行までを標準出力
		`top -l 1|awk 'NR==0,/^$/'`
	* 空行から行末までを標準出力
		`top -l 1|awk '/^$/,0'`
* `bc`コマンド代替： `echo {1..5}|tr ' ' '+'|bc`
`echo {1..5}|awk '{for(i=1;i<=NF;i++)sum+=$i;print sum}'`
* フィールドの再構築
`echo {a..c}|tr ' ' ','|awk -F',' -v OFS=' ' '$1=$1'`
* 大文字/小文字変換
	1. `echo {a..e} |tr -d ' '|awk '$0=toupper($0)'`
	2. `echo {A..E} |tr -d ' '|awk '$0=tolower($0)'`
* piの計算
```
pi=$(awk 'BEGIN{printf"%15.10f¥n",atan2(0,-0)}')
echo $pi
```
* サイコロ乱数
`awk 'BEGIN{srand();print int(rand()*6)+1}'`
* 時刻・時間の取得
	* UNIX時間
		1. `awk 'BEGIN{print srand()+srand()}'`
		2. `awk 'BEGIN{print systime()}'`
	* 時刻
		1. `awk 'BEGIN{"date +%s"|getline;print}'`
		2. `awk 'BEGIN{print strftime("%Y/%m/%d %H:%M:%S", systime())}'`

---


### 苦手コマンド
* `tail`コマンド代替： `seq 100|tail`
	* ナイーブな方法
			`seq 100|awk '{a[NR]=$0}END{for(i=NR-10;i<=NR;i++)print a[i]}'`
	* リング・バッファを活用
			`seq 100|awk '{a[NR%10]=$0}END{for(i=1;i<=10;i++)print a[i%10]}'`
* getlineによる標準入力の読み込み
	```
	BEGIN{
	    while(getline<"-">0){
	        print "NR = " ++nr;
	    }
	    close("-");
	}
	```
* 表示範囲の指定（列）
	1. `echo {a..e}|awk '{for(i=2;i<=NR;i++)a=a OFS $i;print a}'`
	2. `echo {a..e}|awk '{i=2;while(i<=NF)a=a OFS $(i++);print a}'`
* 文字列抽出
	* index関数の活用
		`echo {a..e}|tr -d ' '|awk '$0=substr($0,index($0,"b"))'`
	* match関数の活用
		`echo {a..e}|tr -d ' '|awk 'match($0,/b.*/){print substr($0,RSTART,RLENGTH)}'`
* 文字列置換
	1. `echo {a..e}|tr -d ' '|awk 'sub(/./,"A")'`
	2. `echo {a..e}|tr -d ' '|awk 'gsub(/./,"A")'`
	3. `echo 'sumomomomonouti'|awk '{print gensub(/m/,"M","g",$0);print}'` #gawk
	4. 後方参照（back reference）
		`echo 'sumomomomomonouti'|awk '{print gensub(/(mo)(no)/,"¥¥1¥"¥¥2¥"","g",$0)}'` #gawk
* ハッシュ（連想配列）の取り扱い
	1. 配列の大きさ
	```
	BEGIN{
	    fruits[1]='apple';
	    fruits[2]='orange';
	    fruits[3]='mikan';
	    for(i=1;i<=length(fruits);i++){
	        print i,fruits[i];
	    }
	```
	2. ハッシュの出力順番を正す（awk版）
	```
	BEGIN{
	    fruits_list="apple orange mikan";
	    num_fruits=split(fruits_list, fruits);
	    for(i=1;i<=length(fruits);i++){
	        print i,fruits[i]
	    }
	}
	```
	3. ハッシュの出力順番を正す（gawk版）
	```
	BEGIN{
	    price_of["apple"]=100;
	    price_of["orange"]=200;;
	    price_of["mikan"]=60;
	    PROCINFO["sorted_in"]="@ind_str_asc";  # ポイント
	    for(i in price_of){
	        print i,price_of[i];
	    }
	}
	```
	4. 多次元配列もどき： カンマはカンマにあらず
	```
	a[1 "¥034" 1]="a";　# a[1,1]="a"に同じ
	a[1 "¥034" 2]="b";　# a[1,2]="b"に同じ
	a[2 "¥034" 1]="c";　# a[2,1]="c"に同じ
	a[2 "¥034" 2]="d";　# a[2,2]="d"に同じ
	for(i=1;i<=2;i++){
	    for(j=1;i<=2;j++){
	        print i,j,a[i "¥034" j]
	    }
	}
	```
* 重複行の除去： `echo -e "aaa¥nbbb¥naaa"|sort|uniq`代替
`echo -e "aaa¥nbbb¥naaa"|awk '!(a[$0])++'`
* 双方向パイプ  #gawk
		```
		BEGIN{
		    cmd = sort;
		}
		
		{
		    for (i = 1; i <= NF; i++) {
		        print $i |& cmd;
		    }
		    close(cmd, "to");
		    
		    str = "";
		    while (cmd |& getline > 0) {
		        str = str OFS $0;
		    }
		    close(cmd);
		    sub(/^[ ]/, "", str);
		    
		    print str;
		}
	```

