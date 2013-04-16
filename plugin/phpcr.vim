" phpcr.vim  ENTER FORMAT CODE ON NOWLINE
" Author: h2ero <122750707@qq.com>
" Start Date: 2013-1-14
" Last Change: 2013-3-29
" Version: 0.0.2
" License: MIT license <http://www.opensource.org/licenses/mit-license>

if exists("g:loaded_phpcr") || &cp
    finish
endif
let g:loaded_phpcr = 1

function! phpcr#get_select_lines()
    let s:start_line = line("'<")
    let s:end_line = line("'>")

    if s:start_line == 0 && s:end_line == 0
        return []
    endif

    return getline(s:start_line, s:end_line)
endfunction

function! phpcr#Add_space()

    let s:now_line_nu = line('.')
    "exec "inoremap <CR> <CR>"
    exec "normal! a\<CR>\<Esc>"
    let s:n_line = getline(s:now_line_nu)
    let s:n_indent = indent(s:now_line_nu)


    "format
    let s:n_line =  phpcr#Str_filter(s:n_line)
    let s:n_line = phpcr#Main_format(s:n_line)
    let s:n_line = phpcr#Sql_format(s:n_line)
    let s:n_line =  phpcr#Str_restore(s:n_line)
    
    " <CR> split
    let s:n_line_list = split(s:n_line, '<CR>')

    " write line
    call setline(s:now_line,s:n_line_list[0])
    unlet s:n_line_list[0]
    call append(s:now_line,s:n_line_list)

endfunc

" STR REPLACE AND RESTOR
"----------------------------------------------------------------------
function phpcr#Str_filter(line_content)
    let line_content = a:line_content

    let s:strlist = []
    let s:flag = 0
    let s:index= 0
    while s:flag == 0
        let s:replacelist = matchlist(line_content, '\([''"]\)\{1}\(.\{-}\)\\\@<!\1\{1}')
        if len(s:replacelist) == 0 
            let s:flag = 1
        else
            let s:rstr = s:replacelist[1].s:replacelist[2].s:replacelist[1]
            "escape
            let s:rstr = escape(s:rstr,']\/*')
            call add(s:strlist,['STR'.s:index,s:rstr])
            let line_content = substitute(line_content,s:rstr,'STR'.s:index,'')
            let s:index+=1
        endif
    endwhile
    return line_content
endfunction


" STR RESTOR
"----------------------------------------------------------------------
function! phpcr#Str_restore(line_content)

    let line_content = a:line_content
    let s:index = len(s:strlist) - 1
    while len(s:strlist) > 0
        let line_content = substitute(s:n_line,s:strlist[s:index][0],s:strlist[s:index][1],'')
        unlet s:strlist[s:index]
        let s:index-=1
    endwhile
    return line_content
endfunction

"SQL FORMAT 
"----------------------------------------------------------------------
function! phpcr#Sql_format(line_content)

    let line_content = a:line_content
    " 1 SQL keywords  http://docs.oracle.com/cd/B19306_01/appdev.102/b14261/reservewords.htm
    let s:sql_keywords =  "select,from,where,limit,order,by,desc,asc"
    let s:sql_keywords = substitute(s:sql_keywords,',','\\|','g')

    let line_content = substitute(line_content,'\s*\w\@<!\('.s:sql_keywords.'\)\w\@!\s*',' \U\1 ','g')

    " 2   switch newline
    let line_content = substitute(line_content,'\s*\w\@<!\(FROM\|WHERE\|LIMIT\|ORDER\)\w\@!\s*','<CR>'.repeat(' ', s:n_indent*2).'\1 ','g')
    return line_content

endfunction

"MAIN FORMAT
"----------------------------------------------------------------------
function! phpcr#Main_format(line_content)
    let line_content = a:line_content

    " 1.  =+*<-%/ exclude => != !== .= += <=  ->
    let line_content = substitute(line_content,'\(\w\+\)\@<=\s*\(!\|!=\|+=\|<=\|-=\|*=\|%=\|-\|+\|\.\)\@<!\([%/=*+<-]\+[>]\@!\)\s*',' \3 ','g')

    " >  exclude ->
    let line_content = substitute(line_content,'\s*\(-\|=\)\@<!\(>\)\s*',' \2 ','g')

    " --  ++               eg: change $k ++ or -- $k to $k++ or --$k
    let line_content = substitute(line_content,'\(\w\+\)\s*\([-+]\{2,}\)','\1\2','g')
    let line_content = substitute(line_content,'\([-+]\{2,}\)\s*\(\w\+\)','\1\2','g')

    " 2.  ,                eg : array('a' => 'b', 'c' => 'd')
    let line_content = substitute(line_content,'\s*\([,]\+\)\s*','\1 ','g')

    " 3.  ()               eg : if ( $foo )  exclude define('') 
    let line_content = substitute(line_content,'\(if\|while\|for\|foreach\|switch\)\@<=\s*\([(]\+\)\(.\{-}\)\([)]\+\)\s*',' \2\3\4 ','g')

    " 4.  =>               eg : array('a' => 'b', 'c' => 'd')
    let line_content = substitute(line_content,'\s*\(=>\)\s*',' \1 ','g')

    " 5.  + - * /  exclude ++ --
    "let n_line = substitute(n_line,'\s*\([-]\{2,}\)\s*','\1','g')

    " 6.  != !== += .=     eg : if ($foo !== FALSE)  $a += 5;
    let line_content = substitute(line_content,'\s*\(!=\+\|+=\|\.=\|<=\)\s*',' \1 ','g')

    " 7.  (!               eg : if ( ! $foo)
    let line_content = substitute(line_content,'\s*[(]\@<=\(!\)\s*',' \1 ','g')

    " 8.  || &&            eg : if (($foo && $bar) || ($b && $c))
    let line_content = substitute(line_content,'\s*\(&&\|||\)\s*',' \1 ','g')

    " 9.  (int)            eg : if ( (int) $foo) in up regex will replace it like if((int) $foo), follow will fix it.
    let line_content = substitute(line_content,'\s*(\(int\|boolen\|bool\|float\|string\|binary\|array\|object\|unset\))\s*',' (\1) ','g')

    " 10.  ?:              eg : $foo = $bar ? $foo : $bar;
    let line_content = substitute(line_content,'\s*\(?\)\s*\(.\{-}\)\s*:\@<!\(:\):\@!\s*',' \1 \2 \3 ','g')

    " 11. for(;;)          eg : for($i = 0; $i < 100; $i++) 
    let line_content = substitute(line_content,'\(for\s(\)\@<=\([^;]*\)\(;\)\s*\([^;]*\)\(;\)\s*','\2\3 \4\5 ','g')

    " 12. && ||  replace with and or
    let line_content = substitute(line_content,'\s*||\s*',' OR ','g')
    let line_content = substitute(line_content,'\s*&&\s*',' AND ','g')

    " 13. and or xor not      eg : if (1 AND 2 OR 3 XOR 4)  exclude error word contains or
    let line_content = substitute(line_content,'\s*\w\@<!\(\cand\|\cor\|\cxor\|\cnot\)\w\@!\s*',' \U\1 ','g')

    "" 14. { newline
    "let line_content = substitute(line_content,'\()\|else\)\w\@!\s*{','\1<CR>{','g')
    ""     {} newline
    "let line_content = substitute(line_content,'{\s*}','{<CR>}','g')
    ""     } newline
    "let line_content = substitute(line_content,'}\(else\|elseif\)\w\@!','}<CR>\1','g')


    return line_content
endfunction

"check html and comment then call phpcr#Add_space
"----------------------------------------------------------------------
function! phpcr#Check_exec()
    let s:now_line = line( '.' )
    let s:n_line = getline(s:now_line)
    let s:html = matchstr(s:n_line, '^\s*[*<.#]')
    if empty(s:html) 
        call phpcr#Add_space()
    else
        exec "normal! \<ESC>a\<CR>"
        echo "this is html or Comment"
        "throw "eroor"
    endif
endfunc

au FileType php inoremap <buffer> <CR> <Esc>:call phpcr#Check_exec()<CR>

