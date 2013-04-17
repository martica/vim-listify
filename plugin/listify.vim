:inoremap <C-L> <C-G>u<esc>:call <SID>Listify()<cr>gi
:nnoremap <leader>lt :w<cr>:so %<cr>:call <SID>TestAll()<cr>

function! s:AssertThat( fn, arg, expectation )
    let g:ListifyTestsRun += 1
    let result = call(function("<SID>".a:fn),a:arg)
    if result != a:expectation
        let g:ListifyTestsFailed += 1
        echom "Test Failed: " . a:fn . "(" . string(a:arg)[1:-2] . ") returned ". string(result) . ", expected " string(a:expectation)
    endif
endfunction

function! s:TestFindLastQuote()
    call <SID>AssertThat( "FindLastQuote", ['"', 1], 0 )
    call <SID>AssertThat( "FindLastQuote", ['   "', 3], 3 )
    call <SID>AssertThat( "FindLastQuote", ['   "', 2], -1 )
    call <SID>AssertThat( "FindLastQuote", ['   "\"', 5], 3 )
endfunction

function! s:TestSplitify()
    call <SID>AssertThat( "Splitify", ["1 2 3"], ["1", "2", "3"] )
    call <SID>AssertThat( "Splitify", ['1 "2 4" 3'], ["1", '"2 4"', "3"] )
    call <SID>AssertThat( "Splitify", ['1 "ab c""2 4" 3'], ["1", '"ab c""2 4"', "3"] )
    call <SID>AssertThat( "Splitify", ['1 "ab c\"2 4" 3'], ["1", '"ab c\"2 4"', "3"] )
    call <SID>AssertThat( "Splitify", ['" 1" "ab c\"2 4" 3'], ['" 1"', '"ab c\"2 4"', "3"] )
    call <SID>AssertThat( "Splitify", ['1" 2'], ['1"', '2'] )
endfunction

function! s:TestAll()
    let g:ListifyTestsRun = 0
    let g:ListifyTestsFailed = 0
    call <SID>TestSplitify()
    call <SID>TestFindLastQuote()
    if g:ListifyTestsFailed == 0
        echom "Testing completed: " . g:ListifyTestsRun . " tests run, all passed."
    endif
endfunction

function! s:FindLastQuote( string, start )
    let candidate = strridx( a:string, '"', a:start )
    while candidate > 0 && a:string[candidate-1] == '\'
        let candidate = strridx( a:string, '"', candidate-1 )
    endwhile
    return candidate
endfunction

function! s:Splitify( string )
    " strip leading and trailing whitespace
    " we don't want to empty portions
    let working_string = matchstr( a:string, '^\s*\zs.*\S\ze\s*$' )

    let last_space = strridx( working_string, ' ' )
    let last_quote = <SID>FindLastQuote( working_string, len(working_string) )

    " if there are any quotes after the last_space, search back to find the
    " matching quote and push the space past that
    while last_quote > last_space
        let second_last_quote = <SID>FindLastQuote( working_string, last_quote-1 )
        let last_space = strridx( working_string, ' ', second_last_quote )
        let last_quote = <SID>FindLastQuote( working_string, second_last_quote-1 )
    endwhile

    " if there isn't a last_space just return the whole string
    if last_space == -1
        return [working_string]
    endif

    return <SID>Splitify( working_string[:(last_space-1)] ) + [ working_string[(last_space+1):] ]

endfunction

" This function will yank the text within a paired set of delimiter preceeding
" the cursor position and add commas between the space separated elements.
" It will ignore spaces inside quoted strings. It ignores \" sequences inside
" those strings. 
"
" Ex:
" (1 2 3) => (1, 2, 3)
" (1 "2 3" 4) => (1, "2 3", 4)
" (1 "2 \" 3" 4) => (1, "2 \" 3", 4)
"
function! s:Listify()
    let saved_unnamed_register = @@

    " Get the contents of the preceeding matched pair of delimiters
    execute "normal! y%"

    " break on spaces (outside of quotes, parens, etc) join back together with
    " commas
    let listified = @@[0] . join( <SID>Splitify( @@[1:-2] ), ", " ) . @@[-1:-1]

    execute "normal! c%\<C-R>=listified\<cr>"

    let @@ = saved_unnamed_register
endfunction
