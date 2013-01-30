#phpcr.vim
Auto format php code.
###Conventions and Style 
Reference:  
1. [http://kohanaframework.org/3.0/guide/kohana/conventions](http://kohanaframework.org/3.0/guide/kohana/conventions)  
2. [http://pear.php.net/manual/en/standards.php](http://pear.php.net/manual/en/standards.php)  

// Correct:  
// Incorrect:

* `if($foo=='bar') `    
  `if ($foo == 'bar')`

* `$foo='bar';`     
  `$foo = 'bar';`

* `$foo=(($bar>5)?($bar+$foo):strlen($bar))?Help::$foo%5:$bar%7;`   
  `$foo = (($bar>5) ? ($bar + $foo) : strlen($bar)) ? Hleper::$foo % 5 : $bar % 7;`

* `$foo=(string)$bar;`  
  `$foo = (string) $bar;`
 
* `if((string)$bar)`    
  `if ( (string) $bar)`
  
* `preg_replace('/(\d+) dollar/','$1 euro',$str);`  
  `preg_replace('/(\d+) dollar/', '$1 euro', $str);`

* `if(($foo&&$bar)||($b&&$c))`
  `if (($foo AND $bar) OR ($b && $c))`
  
* `$arr=array('key'=>array('key'=>'value'+'value2'))`   
  `$arr = array('key' => array('key' => 'value' + 'value2'))`
  
* `$a+=$b/$c-$d;`    
  `$a += $b / $c - $d;`
