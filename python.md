# *Michi's* Python Tips
　Pythonはパワフルな言語だ。柔軟なコーディングが可能で覚えることは驚くほど少ない。最小限の知識で実に多くのことができる。しかし、少しでもPythonっぽく書けるようになると、これまで見えていた世界が瞬く間に変わる。そう、全く別の世界になるんだ。  

　ここではPythonのお作法やPythonっぽい書き方をまとめてみる。これらを実践レベルで使えているならPython初級は卒業だ。ただし、中には時代遅れなモノを含んでいるかもしれない。無効になったシンタックスもあるかもしれない。いや、きっとあるだろう。Pythonは日々進化しているから。

　このドキュメントがあなたを異世界へいざなう道標とならんことを。



## オブジェクトの闇
　*オブジェクトを理解することは簡単ではない - Michi*

#### Recipe 1.1　What does  *Identical* mean ?
　「オブジェクトが同じ」とはどういう意味だろう？内容が同じ？それとも指しているものも同じでなきゃダメ？Pythonは（そして**当然**、他の言語も！）両者を厳密に区別する。`==`演算子と`is`演算子の出番だ。
```python
>>> a = ['debunesu', 'gorin', 'hiyokko']
>>> b = a
>>> c = list(a)
```
上の様に変数を定義すると、変数`a`と変数`b`はメモリ空間で同一の場所を指す。アドレスが同じだから、当然データの内容も等しい。一方、変数`c`は変数`a`をコピーして生成した「別の」オブジェクトだ。コピーしたのだから内容は同じだ。しかし、メモリ空間上では変数`c`は変数`a`とは別の場所にある。  
　オブジェクトの内容が同じであるかは`==`演算子で判断できる。`a == b`も`a == c`も`True`が返ってくる。一方で**メモリ空間上において同じものを指す**かは`is`演算子に尋ねよう。`a is b`は`True`だが、`a is c`は`False`だ。

```python
>>> a == b
True

>>> a == c         # the content of a, b and c are the same at least, 
                   # not sure if they point to the same object
True

>>> a is b         # a and b are identical
True

>>> a is c         # a and c point to different objects, to mean, a and c are not identical
False
```



#### Recipe 1.2　コピーのいろいろ




## Pythonの関数はエリカさま
　*フレキシブルに書けるのは、関数がファーストクラスだからだ　- Michi*

#### Recipe 2.1　関数閉包



#### Recipe 2.2　Enter Decorator !
　PythonがDecoratorパターンをビルトイン機能として提供しているのは周知の事実だ。Decoratorを使えばコーラブルの振る舞いを、それ自体を修正することなく変更できる。言い方を変えれば、**コーラブルを一つだけ引数に受け取り、受け取ったコーラブルに自身を拡張する機能を持たせて、同じ名前の新しいコーラブルとして返す。**Decoratorはただのラッパだ。関数閉包を使っても表現できるが、Pythonはファッショナブルなシンタックス・シュガーを用意している。  
　
　今日は調子がイマイチだ。瞼が重い。寝落ちする前にコーヒー買いに行こう。ここにPythonicな自販機がある。1杯100円だ。どうやらソイをトッピングできるらしい。+50円だ。よし、コーヒー3杯に全部ソイをつけよう・・・ 

```python
def get_coffee(cups):
    '''Gets price on coffee'''
    price = 100 * cups
    return price

def add_soy(func):
    '''Option to add soy'''
    def wrapper(*args, **kwargs):
        price = func(*args, **kwargs) + 50 * args[0]
        return f'total: {price} yen'
    return wrapper

>>> get_coffee(3)
300

>>> @add_soy                   # syntactic sugar for decorators
>>> def get_coffee(cups):
>>>     price = 100 * cups
>>>     return price
>>>     
>>> get_coffee(3)              # 3 cups of coffee with soy added
'total: 450 yen'
```
Pythonicな自販機では上のようなコードが（もっと気の利いた実装とともに）動いているだろう。料金を把握する分にはこれで事足りるかもしれない。しかし、上の実装にはちょっとした問題がある。```get_coffee```関数の情報を出力してみよう。
```python
>>> get_coffee.__name__
'wrapper'

>>> get_coffee.__doc__

>>> print(get_coffee)
<function add_soy.<locals>.wrapper at 0x10c2884c0>
```
ひどいもんだろう。  
期待通りの結果を得るには、ビルトイン・モジュール```functools```を使えばいい。簡単だ。

```python
import functools

def add_soy(func):
    '''Option to add soy'''
    @functools.wraps(func)  # decorator to copy all the meta-data to an external function
    def wrapper(*args, **kwargs):
        price = func(*args, **kwargs) + 50 * args[0]
        return f'total: {price} yen'
    return wrapper

>>> @add_soy
>>> def get_coffee(cups):
>>>     price = 100 * cups
>>>     return price
>>>
>>> get_coffee.__name__
'get_coffee'

>>> get_coffee.__doc__
'Gets price on coffee'

>>> print(get_coffee)
<function get_coffee at 0x10c6b5820> 
```



## C++やJavaとはいろいろ違うPythonのクラス
　*ダックタイプで駆け抜けろ　- Michi*
　*Pythonにスーパータイプは必要かって？何寝ぼけたこと言ってるんだ　- Michi*


#### Recipe 3.1　なぜか使われない名前付きタプル
　辞書型を除くコンテナ・オブジェクトはインデックスで要素にアクセスする。サブジェクトなら仕方ないが、Pythonはオブジェクト指向だ。可読性を上げられないものか。  
　ここで名前付きタプルの登場だ。文字通り「名前を付けられるタプル」だ。辞書型風にキーアクセスの様なことができる。結果的に**簡易なクラス（もどき）**を作れる（実は名前付きタプルの型は`type`だ！）。そしてタプルと同様にイミュータブルだ。さらに、名前付きタプルは**メモリ使用効率がよい**。クラスを定義するよりもずっとだ。これはPython内部で標準クラスとして実装されているからだ。  
　
　名前付きタプルを使うには```collections```モジュールからファクトリ関数```namedtuple```を呼び出す。

```python
from collections import namedtuple
```
猫オブジェクトで遊んでみよう。第一引数は生成するオブジェクトの型名だ。そして、第二引数のリストに属性もどきを定義できる。
```python
>>> Cat = namedtuple('Neko', ['name', 'age'])
>>> Cat.__name__    # type name
'Neko'

>>> Cat.__doc__
'Neko(name, age)'

>>> Cat.__repr__
<function collections.Neko.__repr__(self)>
```
`__repr__`属性まであるのだから全くクラスみたいだろう。次は実体化もどきだ。インスタンスmy_catを生成すると、属性みたいに要素へアクセスできる。しかも従来通り、インデックスからもアクセス可能だ。

```python
>>> my_cat = Cat('debunesu', 13)
>>> type(my_cat)
__main__.Neko

>>> my_cat.name
'debunesu'

>>> my_cat.age
13

>>> my_cat[0]
'debunesu'

>>> my_cat[1]
13
```
プロパティにはデフォルト値を設定することもできる。ファクトリ関数内でもできるし、（いささか古めかしい方法だが）コンストラクタを経由して設定することもできる。

```python
>>> Cat = namedtuple('Neko', ['name', 'age'], defaults=('debunesu', 13))
>>> my_cat = Cat()
>>> my_cat
Neko(name='debunesu', age=13)

>>> Cat.__new__.__defaults__ = ('debunesu', 13)   # somewhat classic way
>>> my_cat = Cat()
>>> my_cat
Neko(name='debunesu', age=13)
```
名前付きタプルはイミュータブルだ。だから拡張はできないと思うかもしれない。実は簡単な手続きで新たなプロパティを追加することができる。```_fields```を使って継承もどきだ（実際に継承の「け」の字もしてない！）。ここでは「普通の猫」を「戦う猫」にする。戦士の誕生だ。
```python
>>> Cat = namedtuple('Neko', ['name', 'age'])
>>> Cat.__fields      # returns a set of attributes as a tuple
('name', 'age')

>>> WarriorCat = namedtuple('NekoSenshi', Cat._fields + ('weapon',))
>>> armed_cat = WarrierCat('debunesu', 13, 'claw')
>>> armed_cat
WarrierCat(name='debunesu', age=13, weapon='claw')
```



#### Recipe 3.2　クラスを文字列に変換する：`__repr__()` vs. `__str__()`
　実体化したクラスをコンソールに出力したとき、ガッカリしたことはないだろうか？こんな感じだ。
```python
class Cat:
    def __init__(self, name, age):
        self.name = name
        self.age = age
        
>>> my_cat = Cat('debunesu', 13)
>>> my_cat
<__main__.Cat at 0x10cc866d0>

>>> print(my_cat)
<__main__.Cat at 0x10cc866d0>
```

`my_cat`とタイプしても有用な情報は得られなさそうだ。「Pythonさんよ... ちっとは気を利かせてくれよ」と独りごちそうなところだが、早まってはいけない！Pythonは既に素晴らしい方法を提供している。悪態をついた人は今すぐPythonに謝ろう。特殊メソッド`__repr__()`と`__str__()`の登場だ。（下では分かりやすさのために、敢えて不自然な出力をしている。）

```python
class Cat:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    def __repr__(self):
        return f'__repr__ says, "My cat is {self.name}. She is {self.age}-year old."'
    def __str__(self):
        return f'__str__ says, "My cat is {self.name}. She is {self.age}-year old."'

>>> my_cat = Cat('debunesu', 13)
>>> my_cat
__repr__ says, "My cat is debunesu. She is 13-year old."

>>> print(my_cat)
__str__ says, "My cat is debunesu. She is 13-year old."
```

　実体化したクラスの情報がよく分かるようになった。そのままコンソールに出力すると`__repr__()`メソッド、`print`関数を使うと`__str__()`メソッドの定義に従って出力される。約束を忘れてしまいそうなら、明示的に`repr()`や`str()`へ渡してあげればいい。
```python
>>> repr(my_cat)
__repr__ says, "My cat is debunesu. She is 13-year old."

>>> str(my_cat)
__str__ says, "My cat is debunesu. She is 13-year old."
```
しかし、`list()`や`dict()`などのコンテナは`__repr__()`を好むようだ。
```python
>>> str([my_cat])
[__str__ says, "My cat is debunesu. She is 13-year old."]
```
**ところで、`__str__()`と`__repr__()`は本質的に何が違うんだ？**細かい話をすると長くなってしまう。  
ここでは次の２点に注意すればいい。

1. `__str__()`が定義されていないと`__repr__()`が代わりに呼び出される
2. `__str__()`はエンド・ユーザへ、`__repr__()`はディベロッパへ向けた文字列を返す

まずは1.から。`__repr__()`メソッドは必ずPythonの内部で参照されるので`__repr__()`は定義する癖をつけよう。クラスのアドレスが返ってきても困るからね（アドレスが欲しければ組み込みの`id()`関数を使えばよい）。次に2.について。慣習的に`__str__()`はエンド・ユーザに分かりやすい結果を返すものだ。**可読性**が一番。一方で`__repr__()`はディベロッパ向けの出力だ。これは**デバッグ**にも役立つ。こんな風に`__repr__()`を定義してはどうだろう。
```python
def __repr__(self):
    return f'{self.__class__.__name__}({self.name!r}, {self.age!r})'
```
こうすれば次の結果を得る。実体化したクラスが適切に定義されているか判断できるだろう。
```python
>>> my_cat = Cat('debunesu', 13)
>>> my_cat
Cat('debunesu', 13)
```
以上まとめる。クラスはこの様に定義するとよいだろう。
```python
class Cat:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    def __repr__(self):
        return f'{self.__class__.__name__}({self.name!r}, {self.age!r})'
    def __str__(self):
        return f'My cat is {self.name}. She is {self.age}-year old.'

>>> my_cat = Cat('debunesu', 13)
>>> my_cat
Cat('debunesu', 13)

>>> print(my_cat)
'My cat is debunesu. She is 13-year old.'
```



#### Recipe 3.3　Decorator Revisited



## 転ばぬ先のメタクラス
　*わからなかったら使わない、これ鉄則　- Michi*
　*グースタイプで駆け抜けろ　- Michi*

#### Recipe 4.1　保守に便利な`abc`モジュール
　保守性と可読性を鑑みて、アプリ設計者は「親クラスの実体化を禁止したい」そして「子クラスのメソッド定義忘れに早く気づきたい」と思うことがよくある。そんなときは`abc`モジュールに相談だ。
```python
from abc import ABCMeta, abstractmethod

class Cat(metaclass=ABCMeta):    # Cat is an abstract base class
    @abstractmethod              # purr is an abstract method, and so not implemented
    def purr(self):
        pass
    @abstractmethod              # scratch is an abstract method, and so not implemented
    def scratch(self):
        pass
        
class WildCat(Cat):
    def purr(self):
        print(f'Myaow')

issubclass(WildCat, Cat)
>>> True
```
　ここではCatクラスが親クラスで、継承してWildCatクラスを定義している。`metaclass`に`ABCMeta`を設定することでCatクラスは実体化できなくなる。また抽象メソッドに`abstractmethod`デコレータ を指定するだけで、WildCatクラスにメソッド定義の不備があれば即座に気付くことができる。  
まずは親クラスを実体化してみよう。すると、しっかり怒られる。

```python
>>> neko = Cat()
"TypeError: Can't instantiate abstract class Cat with abstract methods purr, scratch"
```
次にWildCatを実体化しよう。scratchメソッドの実装がないため、期待通り怒られる。
```python
>>> noraneko = WildCat()
"TypeError: Can't instantiate abstract class WildCat with abstract methods purr, scratch"
```
　補足が2つ。1つは`ABCMeta`を指定すると実行時に**わずかなオーバーヘッドが発生してしまう**こと。もう1つは「C++やJavaで書いたコードを移植したい」あるいは「C++やJavaの様に書きたい」ならば`abc`モジュールを活用するとよいこと（本項とは別用途であることに注意）。でもPythonicに書けるならC++やJavaの様に書く必要はない。開発チームの練度に合わせて戦略を決めよう。



#### Recipe 4.2　ジャミとゴンズ、コンスとラクタ
　Pythonのコンストラクタを聞くと```__init__()```メソッドだと答える人がほとんどだという。Pythonのコンストラクタは```__new__()```メソッドだ。もう一度言う。```__new__()```メソッドだ。この特殊メソッドは```classmethod```であり、必ずインスタンスを返す。そして、このインスタンスが```__init__()```メソッドに渡されるのだ。つまり、```__new__()```メソッドはオブジェクトが生成される前に呼び出され、```self```オブジェクトをインスタンス化し、それを```__init__()```メソッドの第一引数に代入する。



#### Recipe 4.3　子クラスが正しく作れてるか検証する： *The earlier, the better*

　メタクラスを妥当性検証に使うと、**子クラスを実体化する前に**エラーを見つけることができる。これはメタクラスが特殊メソッド```__new__()```を定義しており、ここで妥当性の検証がされるからである。```__new__()```は```__init__()```よりも前に呼び出されることを思い出そう。メタクラスは```type```を継承してつくることができる。 

　まずはウォーミング・アップだ。```metaclass```引数にメタクラス```Meta```が渡されると、クラスにまつわる種々の情報が標準出力されるようにした。結果を見ると```meta```が```<class '__main__.Meta'>```、```name```が```Cat```、```bases```が```()```、そして```class_dict```が```{'__module__': '__main__', '__qualname__': 'Cat', 'name': 'debunesu', 'sleep': <function Cat.sleep at 0x103419af0>}```に対応することがわかる。

```python
>>> class Meta(type):
>>>     def __new__(meta, name, bases, class_dict):
>>>         print(meta, name, bases, class_dict)
>>>         return type.__new__(meta, name, bases, class_dict)

>>> class Cat(metaclass=Meta):
>>>     name = 'debunesu'
>>>     @classmethod
>>>     def sleep(cls):
>>>         print(f'Zzz ...')
<class '__main__.Meta'> Cat () {'__module__': '__main__', '__qualname__': 'Cat',
 'name': 'debunesu', 'sleep': <function Cat.sleep at 0x103419af0>}
```
　以下の例では```ValidateCat```がメタクラスだ。クラス辞書```class_dict```を利用して```legs```が4でなければ「それは猫じゃない！」と怒る様に特殊メソッド```__new__()```を修正している。メタクラスを指定するには```metaclass```引数に```ValidateCat```を渡せばよい。ここで何を思ったか、ディベロッパが「傘お化けオブジェクト」（足が1本のあのお化け）を作りたいと思ったとしよう。が、オブジェクトを定義した**直後に**「それは猫じゃない！」と（狙い通り）怒られてしまった。いや、自分が不適切なモノを作ろうとしていたことに気づけたんだ。メタクラスを使わなかったら、実体化するまで傘お化けオブジェクトは残っていたはずだ。**間違いは早く気づくに越したことはない。**
```python
class ValidateCat(type):
    def __new__(meta, name, bases, class_dict):
        if bases != (object,):　　　　　　　　　　　　             # Here's a
            if class_dict['legs'] != 4:                        #  validation
                raise ValueError(f'Cats must have 4 legs !')   #   section
        return type.__new__(meta, name, bases, class_dict)

class Cat(object, metaclass=ValidateCat):   # sets ValidateCat to metaclass
    legs = 4
    def __init__(self, name):
        self.name = name
    @classmethod
    def purr(cls):
        print(f'Myaow !')

# OK, Let's create an object 'kasa-obake' or 'umbrella ghost'
>>> class KasaObake(Cats):
>>>     legs = 1
'ValueError: Cats must have 4 legs !'
```



#### Recipe 4.4　固定観念からの脱却： `__subclasshook__`
　アプリ設計では抽象基底クラスやインタフェースとして親クラスを用意し、継承することで具体的な機能を持つ子クラスを定義することがよくある。C++やJavaではお決まりの作法だ。いや、こうしなくてはいけないだろう。しかし具体的な機能を持ったクラス・オブジェクトが、必ずしも子クラスである必要はない。機能を持ったクラス・オブジェクトが特定のインタフェースを満たしている、つまり**特定のAPIを持ってさえいれば**それでよいのだ。この様なクラスを**仮想サブクラス**という（より正確には「継承されていないが```isinstance()```と```issubclass()```により認識されるクラス」のこと）。ここでも`abc`モジュールが活躍する。そして特殊メソッド```__subclasshook__()```を再実装してあげれば出来上がりだ。  

　特殊メソッド```__subclasshook__()```は```True```, ```False```, ```NotImplemented```のいずれかを返さなくてはいけない。```True```なら、CはCatの子クラスということだ。そして```__subclasshook__```はクラス・メソッドだ。```classmethod```デコレータ を忘れてはいけない。
```python
from abc import ABCMeta
from collections import ChainMap

class Cat(metaclass=ABCMeta):
    @classmethod
    def __subclasshook__(cls, C):
        if cls is Cat:
            attributes = ChainMap(*(B.__dict__ for B in C.__mro__))
            methods = ('purr', 'scratch', 'sleep')
            if all(method in attributes for method in methods):
                return True
            return NotImplemented
```
　さあ、猫の王様を定義しよう。メソッドにpurr, scratch, sleepを完備した無敵の王様だ。実体化されたkingは、まさに猫（Cat）だ。purr, scratch, sleepを持っているからだ。
```python
>>> class KingOfCat:
>>>     def __init__(self, name):
>>>         self.name = name
>>>     def purr(self):
>>>         print(f'Myaow! Waga hai wa {self.name}!')
>>>     def scratch(self):
>>>         print(f'Take this!'):
>>>     def sleep(self):
>>>         print(f'Zzz...'):

>>> king = KingOfCat('debunesu')
>>> isinstance(king, Cat)
True
```
　一方で、ドジな猫を定義してみよう。この猫は伝家の宝刀scratchを失念したらしい。こやつは果たして猫（Cat）なのか。残念なことに、GoofyCatは猫になれなかった。引っ掛けなくなった猫はもはや猫（Cat）ではないのだ。
```python
>>> class  GoofyCat:
>>>     def __init__(self):
>>>         pass
>>>     def purr(self):
>>>         print(f'Hmm... Guess I left something.')
>>>     def sleep(self):
>>>         print(f'Hurray! Time to sleep!'):

>>> doji_neko = GoofyCat()
>>> isinstance(doji_neko, Cat)
False
```



#### Recipe 4.5　固定観念からの脱却：  Decorator Revisited
　本項はメタクラスでない。



## プロパティ
　*乱用は お控えなすって プロパティ　- Michi*

