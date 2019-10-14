## AWK & GNU awk ときどき sed

### 重要コマンド
* 表示範囲の指定（行）
	* 先頭行から空行までを標準出力
		```shell
		top -l 1|awk 'NR==1,/^$/'
		top -l 1|awk 'NR==1,!NF'
		```
		`sed`だと次の様に書ける。
		```shell
		top -l 1 | sed '1,/^$/p' -n
		```
	* 空行から行末までを標準出力
		````shell
		top -l 1|awk '/^$/,0'
		````
		`sed`だと・・・
		
		```shell
		top -l 1 | sed '/^$/,$p' -n
		```
* `bc`コマンド代替： `echo {1..5}|tr ' ' '+'|bc`
`echo {1..5}|awk '{for(i=1;i<=NF;i++)sum+=$i;print sum}'`
* フィールドの再構築
`echo {a..c}|tr ' ' ','|awk -F',' -v OFS=' ' '$1=$1'`
* 大文字/小文字変換
	1. `echo {a..e} |tr -d ' '|awk '$0=toupper($0)'`
	2. `echo {A..E} |tr -d ' '|awk '$0=tolower($0)'`
* piの計算
```shell
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
	```shell
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
	1. `echo {a..e}|tr -d ' '|awk 'sub(/./,"A")'`　or
		 `echo {a..e}|awk 'sub('  *',"")'|awk 'sub(/./,"A")'`
	2. `echo {a..e}|tr -d ' '|awk 'gsub(/./,"A")'`　or
		 `echo {a..e}|awk 'sub('  *',"")'|awk 'gsub(/./,"A")'`
	3. `echo 'sumomomomonouti'|awk '{print gensub(/m/,"M","g",$0);print}'` #gawk
	4. 後方参照（back reference）
		`echo 'sumomomomomonouti'|awk '{print gensub(/(mo)(no)/,"¥¥1¥"¥¥2¥"","g",$0)}'` #gawk
* ハッシュ（連想配列）の取り扱い
	1. 配列の大きさ
	```shell
	BEGIN{
	    fruits[1]='apple';
	    fruits[2]='orange';
	    fruits[3]='mikan';
	    for(i=1;i<=length(fruits);i++){
	        print i,fruits[i];
	    }
	```
	2. ハッシュの出力順番を正す（awk版）
	```shell
	BEGIN{
	    fruits_list="apple orange mikan";
	    num_fruits=split(fruits_list, fruits);
	    for(i=1;i<=length(fruits);i++){
	        print i,fruits[i]
	    }
	}
	```
	3. ハッシュの出力順番を正す（gawk版）
	```shell
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
	```shell
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
	5. 多次元配列　#gawk
	```shell
	BEGIN{
	    a[1][1] = 300;
	    a[2]["Apple"] = 500;
	    a[2][1,2] = 700;
      for(i in a){
          for(j in a[i])[
              print i,j,a[i][j];
          }
      }
	}
	```
* 重複行の除去： `echo -e "aaa¥nbbb¥naaa"|sort|uniq`代替
`echo -e "aaa¥nbbb¥naaa"|awk '!(a[$0])++'`
* 双方向パイプ  #gawk
		```shell
		BEGIN{
		    cmd=sort;
		}
		
		{
		    for(i=1;i<=NF;i++){
		        print $i |& cmd;
		    }
		    close(cmd,"to");
		    
		    str="";
		    while(cmd |& getline>0){
		        str=str OFS $0;
		    }
		    close(cmd);
		    sub(/^[ ]/,"",str);
		    
		    print str;
		}
	```
* セル内にカンマがあるCSVファイル　#gawk
	1. FPATでフィールドそのもののパターンを定義
	`echo 'aaa,"bbb,ccc",ddd'|awk -v FPAT='([^,]+)|(¥"[^¥"]+¥")' '$0=$2'`
	2. patsplit関数を使う　*c.f.* `split`と同じく、戻り値は配列の大きさ
	`echo 'aaa,"bbb,ccc",ddd'|awk '{patsplit($0,arr,"([^,]+)|(¥"[^¥"]+¥")")};print arr[2]'`
* ファイル有無のチェック　#gawk
	```shell
	BEGINFILE{
	    if(ERRNO){
	        print "File does not exist.";
	    }
	    exit;
	}
	```
* Indirect function call
以下のone linerの代替として、IFCを活用した例を示す。
`echo -e '1 2 sum¥n3 4 avg'|awk '{print ($NF=="sum")?$1+$2:($1+$2)/2}'`
```shell
{
    var=$NF;
    print @var($1,$2);
}

function sum(n1,n2){
    return n1+n2;
}

function avg(n1,n2){
    return (n1+n2)/2;
}
```
`echo -e '1 2 sum¥n3 4 avg'|awk -f tmp.awk`

---

### 基本（ `AWK`に限らない ）

#### `printf`文
以下のファイルを例に説明する。
```shell
cat emp.data
> Beth 4.00 0
> Dan 3.75 0
> Kathy 4.00 10
> Mark 5.00 20
> Mary 5.50 22
> Susie 4.25 18
```
* 文字列出力を左詰めする：`%-8s`
```shell
awk '{printf("%-8s $%6.2f¥n", $1, $2*$3)}' emp.data
>Beth     $  0.00
>Dan      $  0.00
>Kathy    $ 40.00
>Mark     $100.00
>Mary     $121.00
>Susie    $ 76.50
```

