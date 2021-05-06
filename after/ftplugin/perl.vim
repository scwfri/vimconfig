" do not include ':' as part of word
setlocal iskeyword-=:

setlocal shiftwidth=2 softtabstop=2 tabstop=2

setlocal foldmethod=indent nofoldenable

if exists("g:pl_formatprg")
    let &l:formatprg=expand(g:pl_formatprg)
else
    let &l:formatprg="perltidy\ -st"
endif

if exists("g:pl_makeprg")
    let &l:makeprg=expand(g:pl_makeprg)
else
    let &l:makeprg="perl\ -c"
endif

" settings for vim-perl
"let g:perl_include_pod = 1
"let g:perl_no_scope_in_variables = 0
"let g:perl_no_extended_vars = 0
