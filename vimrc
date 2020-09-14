" vim settings {{{

" local settings {{{
" load local pre vimrc settings
runtime! local_pre.vim
" }}}

" plugins {{{

"use pathogen if not on vim8, otherwise use vim8 packages
if filereadable(glob('$HOME/.vim/autoload/pathogen.vim')) && v:version < 800
    execute pathogen#infect('pack/bundle/start/{}')
    execute pathogen#infect('pack/bundle/opt/{}')
    execute pathogen#helptags()
endif

" }}}

" colorscheme {{{

set t_Co=256
set t_ut=

function! MyHighlights() abort
    highlight Todo ctermbg=226 ctermfg=235
    " slight adjustment to comments in apprentice.. to make them more readable
    if g:colors_name == 'apprentice'
        highlight Comment ctermfg=242
    endif
endfunction

augroup CustomizeTheme
    autocmd!
    autocmd ColorScheme * call MyHighlights()
augroup END

set background=dark
colorscheme apprentice

" }}}

" initial settings {{{

" basic settings {{{
filetype plugin indent on

set hidden
set autoread
set nomodeline
set ignorecase
set smartcase
set showmatch
set splitbelow
set splitright
set autoindent
set incsearch
set hlsearch
set lazyredraw

" indentation
set shiftwidth=4
let softtabstop = &shiftwidth
set tabstop=4
set shiftround
set expandtab
set smarttab
" commands for adjusting indentation rules manually
command! -nargs=1 Spaces let b:wv = winsaveview() | execute "setlocal tabstop=" . <args> . " expandtab"   | silent execute "%!expand -it "  . <args> . "" | call winrestview(b:wv) | setlocal ts? sw? sts? et?
command! -nargs=1 Tabs   let b:wv = winsaveview() | execute "setlocal tabstop=" . <args> . " noexpandtab" | silent execute "%!unexpand -t " . <args> . "" | call winrestview(b:wv) | setlocal ts? sw? sts? et?

" other setting stuff
set laststatus=2
set backspace=2
set encoding=utf8
set showtabline=3
set clipboard^=unnamed,unnamedplus
set foldmethod=marker
set foldcolumn=0
set formatoptions=qrn1j
set showbreak=↪

" }}}

nnoremap <space> <nop>
let mapleader = "\<space>"
let maplocalleader = "\\"

" enable syntax
if !exists("g:syntax_on")
    syntax enable
endif

set wildmenu
set wildignorecase
set wildmode=list:longest,full
set wildcharm=<C-z>

set tags=./tags;,tags;

" better completion
set omnifunc=syntaxcomplete#Complete
set complete+=d
set completeopt=longest,menuone

" add path fir whitelist
set path+=src/**,config/

" use matchit
runtime! macros/matchit.vim

" easy manpages with <leader>K or :Man <manpage>
runtime! ftplugin/man.vim

" open quickfix automatically when there is something to show
" https://gist.github.com/romainl/ce55ce6fdc1659c5fbc0f4224fd6ad29
augroup AutoQuickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow 
augroup END

" }}}

" backup settings {{{

set undofile
set backup
set backupext=.bak
set noswapfile

" save lots of history
set viminfo='1000,f1,<500

set undodir=~/.vim/tmp/undo// " undo files
set backupdir=~/.vim/tmp/backup// " backups

" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif

" }}}

" statusline {{{

set laststatus=2

function! StatusLineBuffNum()
    let bnum = expand(bufnr('%'))
    return printf("[%d]", bnum)
endfunction

function! StatusLineFiletype()
    return (strlen(&filetype) ? printf("[%s]", &filetype) : '[no ft]')
endfunction

function! StatusLineFormat()
    return winwidth(0) > 160 ? printf("%s | %s", &ff, &fenc) : ''
endfunction

function! StatusLineFileName()
    let fname = '' != expand('%:f') ? printf("%s", expand('%:f')) : '[No Name]'
    return printf("%s", fname)
endfunction

" format the statusline
set statusline=
set statusline+=%{StatusLineBuffNum()}
set statusline+=%<
set statusline+=%{StatusLineFileName()}
set statusline+=%m
set statusline+=%{StatusLineFiletype()}

" right section
set statusline+=%=
" file format
set statusline+=\ %{StatusLineFormat()}

" line number
set statusline+=\ [%l/%L
" column number
set statusline+=:%c
" % of file
set statusline+=\ %p%%]

" }}}

" tabline {{{

" a lot of this taken from https://github.com/mkitt/tabline.vim
" with a few slight tweaks
function! Tabline()
    let s = ''
    for i in range(tabpagenr('$'))
        let tab = i + 1
        let winnr = tabpagewinnr(tab)
        let buflist = tabpagebuflist(tab)
        let bufnr = buflist[winnr - 1]
        let bufname = bufname(bufnr)
        let bufmodified = getbufvar(bufnr, "&mod")
        let gstatus = expand(fugitive#statusline())
        let ostatus = expand(ObsessionStatus())

        let s .= '%' . tab . 'T'
        let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
        let s .= ' ' . tab .':'
        let s .= (bufname != '' ? '['. fnamemodify(bufname, ':t') . ']' : '[No Name]')

        if bufmodified
            let s .= '[+] '
        endif
        let s .= (tab == tabpagenr() ? printf('%s%s', gstatus, ostatus) : '')
    endfor

    let s .= '%#TabLineFill#'
    if (exists("g:tablineclosebutton"))
        let s .= '%=%999XX'
    endif

    return s
endfunction

set tabline=%!Tabline()

" }}}

"}}}

" plugin config {{{

" tagbar {{{
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
let g:show_linenumbers = 1
nnoremap <Space>f :echo tagbar#currenttag('[%s]', '')<CR>
" }}}

" vlime {{{

let g:vlime_cl_use_terminal = 1

" }}}

" undotree {{{

let g:undotree_WindowLayout = 2
nnoremap _U :exec("UndotreeToggle")<cr>

" }}}

" obsession {{{

function! MakeSession()
    ":Obsession g:session_dir . '/*.vim<C-D><BS><BS><BS><BS><BS>'
    let s = 'Obsession'
    execute s
endfunction
nnoremap _ss :call MakeSession()<cr>

function! RestoreSession()
    :source ' . g:session_dir. '/*.vim<C-D><BS><BS><BS><BS><BS>
endfunction
nnoremap _sr :call RestoreSession()<cr>

" freeze session
nnoremap _sf :Obsession<CR>

" }}}

" sneak {{{

map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" }}}

" polyglot {{{

let g:python_highlight_space_errors = 0

" }}}

" git gutter {{{
function! GitGutterStatus()
    let [a, m, r] = GitGutterGetHunkSummary()
    return printf(' [+%d ~%d -%d]', a, m, r)
endfunction
nnoremap _gs :echo GitGutterStatus()<CR>
nnoremap _gt :GitGutterToggle<CR>
" }}}

" }}}

" functions {{{

" Append modeline after last line in buffer. {{{
" from https://vim.fandom.com/wiki/Modeline_magic
function! AppendModeline()
    let l:modeline = printf(" vim: set ts=%d sw=%d %set:",
                \ &tabstop, &shiftwidth, &expandtab ? '' : 'no')
    let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
    call append(line('0'), l:modeline)
endfunction
nnoremap <silent> _ml :call AppendModeline()<CR>

" }}}

" gitgrep {{{
function! GitGrep(...)
    " store grepprg to restore after running
    let save = &grepprg
    " set grepprg to git grep for use in function
    set grepprg=git\ grep\ -n\ $*
    let s = 'grep!'
    let s = 'silent ' . s
    for i in a:000
        let s = s . ' ' . i
    endfor
    let s = s . ' | copen'
    execute s
    " restore grepprg to original setting
    let &grepprg = save
endfunction
command! -nargs=+ GitGrep call GitGrep(<f-args>)
" }}}

" generate tags quickly {{{
function! GenerateTags()
    :! ctags -R
endfunction
command! Tags call GenerateTags()
" }}}

" highlight interesting words {{{

" credit: https://github.com/paulirish/dotfiles/blob/master/.vimrc

function! HiInterestingWord(n) " {{{
    " Save our location.
    normal! mz

    " Yank the current word into the z register.
    normal! "zyiw

    " Calculate an arbitrary match ID.  Hopefully nothing else is using it.
    let mid = 86750 + a:n

    " Clear existing matches, but don't worry if they don't exist.
    silent! call matchdelete(mid)

    " Construct a literal pattern that has to match at boundaries.
    let pat = '\V\<' . escape(@z, '\') . '\>'

    " Actually match the words.
    call matchadd("InterestingWord" . a:n, pat, 1, mid)

    " Move back to our original location.
    normal! `z
endfunction " }}}

" Mappings {{{
nnoremap <silent> _1 :call HiInterestingWord(1)<cr>
nnoremap <silent> _2 :call HiInterestingWord(2)<cr>
nnoremap <silent> _3 :call HiInterestingWord(3)<cr>
nnoremap <silent> _4 :call HiInterestingWord(4)<cr>
nnoremap <silent> _5 :call HiInterestingWord(5)<cr>
nnoremap <silent> _6 :call HiInterestingWord(6)<cr>
" }}}

" Default Highlights {{{
hi def InterestingWord1 guifg=#000000 ctermfg=16 guibg=#ffa724 ctermbg=214
hi def InterestingWord2 guifg=#000000 ctermfg=16 guibg=#aeee00 ctermbg=154
hi def InterestingWord3 guifg=#000000 ctermfg=16 guibg=#8cffba ctermbg=121
hi def InterestingWord4 guifg=#000000 ctermfg=16 guibg=#b88853 ctermbg=137
hi def InterestingWord5 guifg=#000000 ctermfg=16 guibg=#ff9eb8 ctermbg=211
hi def InterestingWord6 guifg=#000000 ctermfg=16 guibg=#ff2c4b ctermbg=195
" }}}
" }}}

" clean whitespace {{{

function! StripTrailingWhitespace()
    if !&binary && &filetype != 'diff'
        normal mz
        normal Hmy
        %s/\s\+$//e
        normal 'yz<CR>
        normal `z
    endif
endfunction

command! CleanWhitespace call StripTrailingWhitespace()
nnoremap _W :call StripTrailingWhitespace()<cr>

" }}}

" line number management {{{

function! ToggleLineNum()
    if &number || &relativenumber
        set nonumber
        set norelativenumber
    else
        set number
        set relativenumber
    endif
endfunction

command! ToggleLineNum call ToggleLineNum()
nnoremap _n :call ToggleLineNum()<cr>

" }}}

" move lines {{{
function! MoveLineUp(arg)
    execute ":.m-2<CR>"
endfunction

function! MoveLineDown(arg)
    execute ":.m+1<CR>"
endfunction

nnoremap <silent> _j :set operatorfunc=MoveLineUp<CR>g@<CR>
nnoremap <silent> _k :set operatorfunc=MoveLineDown<CR>g@<CR>
" }}}

" show declaration {{{
" from https://gist.github.com/romainl/a11c6952f012f1dd32c26fad4fa82e43
function! ShowDeclaration(global) abort
	let pos = getpos('.')
	if searchdecl(expand('<cword>'), a:global) == 0
		let line_of_declaration = line('.')
		execute line_of_declaration . "#"
	else
		echo 'Sorry, no declaration found.'
	endif
	call cursor(pos[1], pos[2])
endfunction
nnoremap _d :call ShowDeclaration(0)<CR>
nnoremap _D :call ShowDeclaration(1)<CR>
" }}}

" substitute operator {{{
"credit: https://gist.github.com/romainl/b00ccf58d40f522186528012fd8cd13d
function! Substitute(type, ...)
	let cur = getpos("''")
	call cursor(cur[1], cur[2])
	let cword = expand('<cword>')
	execute "'[,']s/" . cword . "/" . input(cword . '/')
	call cursor(cur[1], cur[2])
endfunction
nmap <silent> _s  m':set operatorfunc=Substitute<CR>g@

" Usage:
"   <key>ipfoo<CR>         Substitute every occurrence of the word under
"                          the cursor with 'foo' n the current paragraph
"   <key>Gfoo<CR>          Same, from here to the end of the buffer
"   <key>?bar<CR>foo<CR>   Same, from previous occurrence of 'bar'
"                          to current line
" }}}

" Global <pattern> -> location list {{{
" original soure: https://gist.github.com/romainl/f7e2e506dc4d7827004e4994f1be2df6
set errorformat^=%f:%l:%c\ %m
" command! -nargs=1 Global lgetexpr filter(map(getline(1,'$'), {key, val -> expand("%") . ":" . (key + 1) . ":1 " . val }), { idx, val -> val =~ <q-args> })
command! -nargs=1 Global lgetexpr filter(map(getline(1,'$'), 'expand("%") . ":" . (v:key + 1) . ":1 " . v:val'), 'v:val =~ <q-args>') | lopen

nnoremap <Space>g :Global<Space>
" }}}

" cdo/cfdo if not available {{{
" from: https://www.reddit.com/r/vim/comments/iiatq6/is_there_a_good_way_to_do_vim_global_find_and/
if !exists(':cdo')
    command! -nargs=1 -complete=command Cdo try | sil cfirst |
        \ while 1 | exec <q-args> | sil cn | endwhile |
        \ catch /^Vim\%((\a\+)\)\=:E\%(553\|42\):/ |
        \ endtry

    command! -nargs=1 -complete=command Cfdo try | sil cfirst |
        \ while 1 | exec <q-args> | sil cnf | endwhile |
        \ catch /^Vim\%((\a\+)\)\=:E\%(553\|42\):/ |
        \ endtry
endif
" }}}

"}}}

" custom mappings and stuff {{{

" easily switch windows
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" easy buffer and tab switching
function! BuffNext(arg)
    :bnext
endfunction
function! BuffPrev(arg)
    :bprevious
endfunction
function! TabNext(arg)
    :tabnext
endfunction
function! TabPrev(arg)
    :tabprevious
endfunction
nnoremap gb :set operatorfunc=BuffNext<CR>g@<CR>
nnoremap gB :set operatorfunc=BuffPrev<CR>g@<CR>
nnoremap gt :set operatorfunc=TabNext<CR>g@<CR>
nnoremap gT :set operatorfunc=TabPrev<CR>g@<CR>
nnoremap <BS> <C-^>

" default Y mapping is just.. wrong
nnoremap Y y$

" ilist
nnoremap _i :Ilist!<Space>
nnoremap _I :Ilist! <C-r>=expand("<cword>")<CR><CR>

" ijump
nnoremap <Space>i :ijump! <C-r>=expand("<cword>")<CR><CR>

" quick jump to tag under curosr
nnoremap _t :tjump <C-r>=expand("<cword>")<CR><CR>

" g search
nnoremap \g :g//#<Left><Left>
nnoremap \|G :g/<C-r>=expand("<cword>")<CR>/#<CR>

" quick search and replace
" https://github.com/romainl/minivimrc/blob/master/vimrc
nnoremap _rp :'{,'}s/\<<C-r>=expand("<cword>")<CR>\>/
nnoremap _ra :%s/\<<C-r>=expand("<cword>")<CR>\>//c<Left><Left>

" echo current file full path
nnoremap _fp :echo expand("%:p")<cr>

" view all todo in quickfix window
nnoremap <silent> _vt :exec("lvimgrep /todo/j %")<cr>:exec("lopen")<cr>

" vimgrep for word under cursor in current file and open in location list
nnoremap <silent> \gr :exec("lvimgrep /".expand("<cword>")."/j %")<cr>:exec("lopen")<cr>

" vimgrep for word under cursor in current directory open in quickfix
nnoremap <silent> \gR :exec("vimgrep /".expand("<cword>")."/j **/*")<cr>:exec("copen")<cr>

" Do and insert results of fancy math equations via python
" from https://github.com/alerque/que-vim/blob/master/.config/nvim/init.vim
command! -nargs=+ Calc :r! python3 -c 'from math import *; print (<args>)'

" auto center when going to prev/next function definition
nnoremap [[ [[zz
nnoremap ]] ]]zz

" show list of digraphs -- special symbols
nnoremap _vd :help digraphs<cr>:179<cr>zt

" toggle line and column markers
nnoremap <silent> \c :exec("set cursorcolumn!")<cr>
nnoremap <silent> \r :exec("set cursorline!")<cr>

" upper case last word using ctrl+u
inoremap <C-u> <C-o>gUiw<C-o>e<C-o>a

" Shift-Tab enters actual tab
inoremap <S-Tab> <C-v><Tab>

" stay where you are on * from fatih (http://www.github.com/fatih/dotfiles)
nnoremap <silent> * :let stay_star_view = winsaveview()<cr>*:call winrestview(stay_star_view)<cr>

" tagbar
nnoremap <silent> \\ :exec("TagbarOpen('j')")<cr>

" Disable highlight
nnoremap <silent> <space><cr> :nohlsearch<cr>

" Switch CWD to the directory of the open buffer
nnoremap _Cd :cd %:p:h<cr>:pwd<cr>

" netrw
nnoremap <leader>o :Sexplore!<cr>
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_winsize = 25

" terminal mode {{{
if has('terminal')
    " easy terminal exit
    tnoremap <esc> <C-\><C-n>
endif
" }}}

" easy editing {{{
nnoremap <Space>ev :vsplit $MYVIMRC<cr>
nnoremap <silent> <Space>es :source $MYVIMRC<cr> :echo "sourced"$MYVIMRC""<cr>
" }}}

" operator mappings {{{
onoremap p i(
onoremap in( :<C-u>normal! f(vi(<cr>
onoremap il( :<C-u>normal! F)vi(<cr>
" }}}

" }}}

" local settings {{{
" load local pre vimrc settings
runtime! local_post.vim
" }}}
