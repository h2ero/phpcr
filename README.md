#phpcr.vim
Auto format php code.
ascii.io : http://ascii.io/a/3199
###Conventions and Style 
Reference:  
1. [http://kohanaframework.org/3.0/guide/kohana/conventions](http://kohanaframework.org/3.0/guide/kohana/conventions)  
2. [http://pear.php.net/manual/en/standards.php](http://pear.php.net/manual/en/standards.php)  
3. [https://github.com/php-fig/fig-standards/tree/master/accepted](https://github.com/php-fig/fig-standards/tree/master/accepted)

```php
// Correct:  
// Incorrect:

if($foo=='bar')     
if ($foo == 'bar')

$foo='bar';     
$foo = 'bar';

$foo=(($bar>5)?($bar+$foo):strlen($bar))?Help::$foo%5:$bar%7;   
$foo = (($bar>5) ? ($bar + $foo) : strlen($bar)) ? Hleper::$foo % 5 : $bar % 7;

$foo=(string)$bar;  
$foo = (string) $bar;

if((string)$bar)    
if ( (string) $bar)

preg_replace('/(\d+) dollar/','$1 euro',$str);  
preg_replace('/(\d+) dollar/', '$1 euro', $str);

if(($foo&&$bar)||($b&&$c))
if (($foo AND $bar) OR ($b && $c))

$arr=array('key'=>array('key'=>'value'+'value2'))   
$arr = array('key' => array('key' => 'value' + 'value2'))

$a+=$b/$c-$d;    
$a += $b / $c - $d;

$sql = "select * from table1 where id = 11 and ip = '127.0.0.1'";
$sql = "SELECT *
    FROM table1
    WHERE id = 11 AND ip = '127.0.0.1'";
    
$db->from('table')->join('table2')->where(array('id'=>1));
$db->from('table')->join('table2')->where(array('id' => 1));

```
###.vimrc

```viml

syntax enable                " 打开语法高亮 
syntax on                    " 开启文件类型侦测
filetype indent on           " 针对不同的文件类型采用不同的缩进格式
filetype plugin on           " 针对不同的文件类型加载对应的插件

```

More:
----------
* PHP_CodeSniffer: http://pear.php.net/package/PHP_CodeSniffer/redirected 
* PHP-CS-Fixer: https://github.com/fabpot/PHP-CS-Fixer
