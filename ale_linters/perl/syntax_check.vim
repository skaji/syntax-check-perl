" Original author:
"   https://github.com/w0rp/ale/blob/master/ale_linters/perl/perl.vim
"   Author: Vincent Lequertier <https://github.com/SkySymbol>
"   Description: This file adds support for checking perl syntax

let g:ale_perl_syntax_check_executable =
\   get(g:, 'ale_perl_syntax_check_executable', 'perl')

let g:ale_perl_syntax_check_config =
\   get(g:, 'ale_perl_syntax_check_config', g:plug_home . '/syntax-check-perl/config/default.pl')

let g:ale_perl_syntax_check_options =
\   get(g:, 'ale_perl_syntax_check_options', '-Ilib')

function! ale_linters#perl#syntax_check#GetConfig(buffer) abort
    return ale#Var(a:buffer, 'perl_syntax_check_config')
endfunction

function! ale_linters#perl#syntax_check#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'perl_syntax_check_executable')
endfunction

function! ale_linters#perl#syntax_check#GetCommand(buffer) abort
    let l:config = ale_linters#perl#syntax_check#GetConfig(a:buffer)
    if filereadable(l:config)
        return ale#Escape(ale_linters#perl#syntax_check#GetExecutable(a:buffer))
        \    . ' ' . ale#Var(a:buffer, 'perl_syntax_check_options')
        \    . ' ' . g:plug_home . '/syntax-check-perl/syntax-check'
        \    . ' --config ' . ale#Escape(ale_linters#perl#syntax_check#GetConfig(a:buffer))
        \    . ' %s %t'
    else
        echo "[ERROR] ale plugin syntax-check-perl: Couldn't read config file " . l:config
    endif
endfunction

function! ale_linters#perl#syntax_check#Handle(buffer, lines) abort
    let l:pattern = '\(.\+\) at \(.\+\) line \(\d\+\)'
    let l:output = []
    let l:basename = expand('#' . a:buffer . ':t')

    let l:seen = {}
    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:line = l:match[3]
        let l:file = l:match[2]
        let l:text = l:match[1]

        if (0 == match(l:text, '=MarkWarnings=') )
          let l:type = 'W'
          let l:text = substitute(l:text, "^=MarkWarnings=" , "", "")
        else
          let l:type = 'E'
        endif

        if ale#path#IsBufferPath(a:buffer, l:file)
        \ && !has_key(l:seen,l:line)
        \ && (
        \   l:text isnot# 'BEGIN failed--compilation aborted'
        \   || empty(l:output)
        \ )
            call add(l:output, {
            \   'lnum': l:line,
            \   'text': l:text,
            \   'type': l:type,
            \})

            let l:seen[l:line] = 1
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('perl', {
\   'name': 'syntax-check',
\   'executable_callback': 'ale_linters#perl#syntax_check#GetExecutable',
\   'output_stream': 'both',
\   'command_callback': 'ale_linters#perl#syntax_check#GetCommand',
\   'callback': 'ale_linters#perl#syntax_check#Handle',
\})
