"
" phpcr.vim  ENTER FORMAT CODE ON NOWLINE
"
"  __________   ___ ___ __________ _________ __________ 
" \______   \ /   |   \\______   \\_   ___ \\______   \
"  |     ___//    ~    \|     ___//    \  \/ |       _/
"  |    |    \    Y    /|    |    \     \____|    |   \
"  |____|     \___|_  / |____|     \______  /|____|_  /
"                   \/                    \/        \/ 
"
" Author: h2ero <122750707@qq.com>
" Start Date: 2013-1-14
" Last Change: 2014-02-13 09:50:39
" Version: 0.1.2
" License: MIT license <http://www.opensource.org/licenses/mit-license>

if exists("g:loaded_phpcr") || &cp
    finish
endif

if !exists("g:sql_keywords")
    let g:sql_keywords = ''
endif

let g:loaded_phpcr = 1
let g:phpcr_enable = 1

let g:phpcr_replace_list = {}
"{{{ phpcr_replace_list init
" 1.  =+*<-%/ exclude => != !== .= += <=  ->
let g:phpcr_replace_list['\(\w\+\|]\)\@<=\s*\(!\|!=\|+=\|<=\|>=\|-=\|*=\|%=\|-\|+\|\.\)\@<!\([%/=*+<-]\+[>]\@!\)\s*']=' \3 '
" >  exclude ->
let g:phpcr_replace_list['\s*\(-\|=\)\@<!\(>=\|>\)\s*']=' \2 '
" --  ++               eg: change $k ++ or -- $k to $k++ or --$k
let g:phpcr_replace_list['\(\w\+\)\s*\([-+]\{2,}\)']='\1\2'
let g:phpcr_replace_list['\([-+]\{2,}\)\s*\(\w\+\)']='\1\2'
" 2.  , eg : array('a' => 'b', 'c' => 'd')
let g:phpcr_replace_list['\s*\([,]\+\)\s*']='\1 '
" 3.  ()               eg : if ( $foo )  exclude define('') 
let g:phpcr_replace_list['\(if\|while\|for\|foreach\|switch\)\@<=\s*\([(]\+\)\(.\{-}\)\([)]\+\)\s*']=' \2\3\4 '
" 4.  =>               eg : array('a' => 'b', 'c' => 'd')
let g:phpcr_replace_list['\s*\(=>\)\s*']=' \1 '
" 5.  + - * /  exclude ++ --
let g:phpcr_replace_list['\s*\([-]\{2,}\)\s*']='\1'
" 6.  != !== += .=     eg : if ($foo !== FALSE)  $a += 5;
let g:phpcr_replace_list['\s*\(!=\+\|+=\|\.=\|<=\)\s*']=' \1 '
" 7.  (!               eg : if ( ! $foo)
let g:phpcr_replace_list['\s*[(]\@<=\(!\)\s*']=' \1 '
" 8.  || &&            eg : if (($foo && $bar) || ($b && $c))
let g:phpcr_replace_list['\s*\(&&\|||\)\s*']=' \1 '
" 9.  (int)            eg : if ( (int) $foo) in up regex will replace it like if((int) $foo), follow will fix it.
let g:phpcr_replace_list['\s*(\(int\|boolen\|bool\|float\|string\|binary\|array\|object\|unset\))\s*']=' (\1) '
" eg : $data[(string) $int] if((string) $str)
let g:phpcr_replace_list['\((\|[\)\s*(\(int\|boolen\|bool\|float\|string\|binary\|array\|object\|unset\))\s*']='\1(\2) '
" 10.  ?:              eg : $foo = $bar ? $foo : $bar;
let g:phpcr_replace_list['\s*\(?\)\s*\(.\{-}\)\s*:\@<!\(:\):\@!\s*']=' \1 \2 \3 '
" 11. for(;;)          eg : for($i = 0; $i < 100; $i++) 
let g:phpcr_replace_list['\(for\s(\)\@<=\([^;]*\)\(;\)\s*\([^;]*\)\(;\)\s*']='\2\3 \4\5 '
" 12.AND OR
" let g:phpcr_replace_list['\s*||\s*']=' OR '
" let g:phpcr_replace_list['\s*&&\s*']=' AND '
" 13. and or xor not      eg : if (1 AND 2 OR 3 XOR 4)  exclude error word contains or
let g:phpcr_replace_list['\s*\w\@<!\(\cand\|\cor\|\cxor\|\cnot\)\w\@!\s*']=' \U\1 '
" 14. { space
let g:phpcr_replace_list['\()\|else\)\w\@!\s*{']='\1 {'
" {} space newline
let g:phpcr_replace_list['\s*{\s*}']=' {<CR>}'
" } space
let g:phpcr_replace_list['}\s*\(else\|elseif\)\w\@!']='} \1'

"}}}

function! phpcr#Toggle()
    let g:phpcr_enable = g:phpcr_enable == 1 ? 0 : 1 
endfunction

function! phpcr#Get_select_lines()

    let start_line = line("'<")
    let end_line = line("'>")

    if start_line == 0 && end_line == 0
        return []
    endif

    call phpcr#init()
    let s:line_list = range(start_line,end_line)
    for n_line in s:line_list

        "skip space line
        if match(getline(n_line), "^\s*$") == -1 
            call phpcr#Add_space(n_line)
        endif

        let n_line += g:increase_line_num 
    endfor

endfunction
function phpcr#Multi_format()
    if g:phpcr_enable == 1
        call phpcr#Get_select_lines()
    else
        "nothing
    endif
endfunction

function! phpcr#Add_space(line_num)

    let line_num = a:line_num
    let n_line = getline(line_num)
    let s:n_indent = indent(line_num)


    "format
    let n_line = phpcr#Str_filter(n_line)
    let n_line = phpcr#Main_format(n_line)
    let n_line = phpcr#Sql_format(n_line)
    let n_line = phpcr#Str_restore(n_line)
    
    " <CR> split
    let n_line_list = split(n_line, '<CR>')
    if !exists("g:increase_line_num")
        if len(n_line_list) != 0
            call setline(line_num,n_line_list[0])
            unlet n_line_list[0]
            call append(line_num,n_line_list)
        endif
        return 
    endif

    if len(n_line_list) != 0
        " write line
        call setline(line_num,n_line_list[0])
        call phpcr#Line_indent(line_num+1)
        unlet n_line_list[0]
        let g:increase_line_num += len(n_line_list) 
        call append(line_num,n_line_list)
    endif

endfunction

function phpcr#init()
    let g:increase_line_num = 0
endfunction

" STR REPLACE AND RESTOR
"----------------------------------------------------------------------
function phpcr#Str_filter(line_content)
    let line_content = a:line_content

    let s:strlist = []
    let s:flag = 0
    let s:index= 0
    while s:flag == 0
        "todo $str= '\\'.'/'; this string can't be replaced right
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
        let line_content = substitute(line_content,s:strlist[s:index][0],s:strlist[s:index][1],'')
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
    let s:sql_keywords = "select,from,where,limit,order,group,by,desc,asc,join,on,in,left,"
    let s:sql_keywords = s:sql_keywords.g:sql_keywords
    let s:sql_keywords = substitute(s:sql_keywords,',','\\|','g')

    let line_content = substitute(line_content,'\(>\)\@<!\<\('.s:sql_keywords.'\)\>\((\)\@!','\U\2','gi')

    if s:n_indent == 0 
        let s:n_next_indent = 4
    else
        let s:n_next_indent = s:n_indent+4
    endif

    " 2   switch newline
    let line_content = substitute(line_content,'\s\+\(FROM\|WHERE\|LIMIT\|ORDER\|JOIN\)\s\+','<CR>'.repeat(' ', s:n_next_indent).'\1 ','g')
    return line_content

endfunction

"line indent
function! phpcr#Line_indent(line_num)
    let line_num = a:line_num
    " exec "normal! \<ESC>o"
    let v:lnum = line_num
    let n_next_indent = GetPhpIndent()
    let line_content = getline(line_num)
    let line_content = substitute(line_content,'^\s*',repeat(' ', n_next_indent+1).'\1','g')
    call setline(line_num, line_content)
    call setpos('.', [0, line_num , n_next_indent+1, 0])
    exec "startinsert"
endfunction


"MAIN FORMAT
"----------------------------------------------------------------------
function! phpcr#Main_format(line_content)
    let line_content = a:line_content
    for pat in keys(g:phpcr_replace_list)
        let sub = g:phpcr_replace_list[pat]
        let line_content = substitute(line_content, pat, sub, 'g')
    endfor
    return line_content
endfunction

"check html and comment then call phpcr#Add_space
"----------------------------------------------------------------------
function! phpcr#Check_exec()
    let s:line_num = line( '.' )
    let s:n_line = getline(s:line_num)
    let s:html = matchstr(s:n_line, '^\s*[*<.#]')
    if empty(s:html) 
        "exec "inoremap <CR> <CR>"
        exec "normal! a\<CR>\<Esc>"
        call phpcr#init()
        call phpcr#Add_space(s:line_num)
        exec "normal! =="
    else
        exec "normal! \<ESC>a\<CR>"
        echo "this is html or Comment"
        "throw "eroor"
    endif
endfunction

function phpcr#run()
    if g:phpcr_enable == 1
       call phpcr#Check_exec() 
    else
       exec "normal! \<ESC>o"
       let s:line_num = line( '.' )+1
       call phpcr#Line_indent(s:line_num)
    endif
endfunction

autocmd FileType php inoremap <buffer> <CR> <Esc>:call phpcr#run()<CR>

"command
command! -bang -range -nargs=* Phpcr  call phpcr#Multi_format()
command!  PhpcrToggle  call phpcr#Toggle()
command!  PhpcrLineFormat  call phpcr#Add_space(line( '.' ))
