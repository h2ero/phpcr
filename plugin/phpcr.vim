" phpcr.vim  ENTER FORMAT CODE ON NOWLINE
" Author: h2ero <122750707@qq.com>
" Start Date: 2013-1-14
" Last Change: 2013-1-30
" Version: 0.0.1
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

    " str replace
    let s:strlist = []
    let s:flag = 0
    let s:index= 0
    while s:flag == 0
        let s:replacelist = matchlist(s:n_line, '\([''"]\)\{1}\(.\{-}\)\\\@<!\1\{1}')
        if len(s:replacelist) == 0 
            let s:flag = 1
        else
            let s:rstr = s:replacelist[1].s:replacelist[2].s:replacelist[1]
            call add(s:strlist,['STR'.s:index,s:rstr])
            let s:n_line = substitute(s:n_line,s:rstr,'STR'.s:index,'')
            let s:index+=1
        endif
    endwhile

    " 1.  =+*<-%/ exclude => != !== .= += <= 
    let s:n_line = substitute(s:n_line,'\s*\(!\|!=\|+=\|<=\|\.\)\@<!\([%/=*+<-]\+[>]\@!\)\s*',' \2 ','g')

    " 2.  ,                eg : array('a' => 'b', 'c' => 'd')
    let s:n_line = substitute(s:n_line,'\s*\([,]\+\)\s*','\1 ','g')

    " 3.  ()               eg : if ( $foo )  exclude define('') 
    let s:n_line = substitute(s:n_line,'\(if\|while\|for\|foreach\|switch\)\@<=\s*\([(]\+\)\(.\{-}\)\([)]\+\)\s*',' \2\3\4 ','g')

    " 4.  =>               eg : array('a' => 'b', 'c' => 'd')
    let s:n_line = substitute(s:n_line,'\s*\(=>\)\s*',' \1 ','g')

    " 5.  + - * /  exclude ++ --
    "let n_line = substitute(n_line,'\s*\([-]\{2,}\)\s*','\1','g')

    " 6.  != !== += .=     eg : if ($foo !== FALSE)  $a += 5;
    let s:n_line = substitute(s:n_line,'\s*\(!=\+\|+=\|\.=\|<=\)\s*',' \1 ','g')

    " 7.  (!               eg : if ( ! $foo)
    let s:n_line = substitute(s:n_line,'\s*[(]\@<=\(!\)\s*',' \1 ','g')

    " 8.  || &&            eg : if (($foo && $bar) || ($b && $c))
    let s:n_line = substitute(s:n_line,'\s*\(&&\|||\)\s*',' \1 ','g')

    " 9.  (int)            eg : if ( (int) $foo) in up regex will replace it like if((int) $foo), follow will fix it.
    let s:n_line = substitute(s:n_line,'\s*(\(int\|bool\|float\|string\|binary\|array\|object\|unset\))\s*',' (\1) ','g')

    " 10.  ?:              eg : $foo = $bar ? $foo : $bar;
    let s:n_line = substitute(s:n_line,'\s*\(?\)\s*\(.\{-}\)\s*:\@<!\(:\):\@!\s*',' \1 \2 \3 ','g')

    " 11. for(;;)          eg : for($i = 0; $i < 100; $i++) 
    let s:n_line = substitute(s:n_line,'\(for\s(\)\@<=\([^;]*\)\(;\)\s*\([^;]*\)\(;\)\s*','\2\3 \4\5 ','g')

    " 12. && ||  replace with and or
    let s:n_line = substitute(s:n_line,'\s*||\s*',' OR ','g')
    let s:n_line = substitute(s:n_line,'\s*&&\s*',' AND ','g')

    " 13. and or xor not      eg : if (1 AND 2 OR 3 XOR 4)  exclude error word contains or
    let s:n_line = substitute(s:n_line,'\s*\w\@<!\(\cand\|\cor\|\cxor\|\cnot\)\w\@!\s*',' \U\1 ','g')

    " 14. { newline
    let s:n_line = substitute(s:n_line,'\()\|else\)\w\@!\s*{','\1<CR>{','g')
    "     {} newline
    let s:n_line = substitute(s:n_line,'{\s*}','{<CR>}','g')
    "     } newline
    let s:n_line = substitute(s:n_line,'}\(else\|elseif\)\w\@!','}<CR>\1','g')

    " str restore
    let s:index = len(s:strlist) - 1
    while len(s:strlist) > 0
        let s:n_line = substitute(s:n_line,s:strlist[s:index][0],s:strlist[s:index][1],'')
        unlet s:strlist[s:index]
        let s:index-=1
    endwhile

    " <CR> split
    let s:n_line_list = split(s:n_line, '<CR>')

    " write line
    call setline(s:now_line,s:n_line_list[0])
    unlet s:n_line_list[0]
    call append(s:now_line,s:n_line_list)

endfunc

function! phpcr#Check_exec()
    let s:now_line = line( '.' )
    let s:n_line = getline(s:now_line)
    let s:html = matchstr(s:n_line, '^\s*[<.#]')
    if empty(s:html) 
        call phpcr#Add_space()
    else
        exec "normal! \<ESC>a\<CR>"
        echo "this is html"
        "throw "eroor"
    endif
endfunc

au FileType php inoremap <CR> <Esc>:call phpcr#Check_exec()<CR>
