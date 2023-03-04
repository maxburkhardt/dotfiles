" =============================================================================
"                               General settings
" =============================================================================
set nocompatible        " iMproved.

set autoindent          " Copy indent from current line on starting a new line.
set backspace=indent,eol,start " Backspacing over everything in insert mode.
set hidden              " Allow for putting dirty buffers in background.
set history=1024        " Lines of command history
set ignorecase          " Case-insensitive search
set incsearch           " Jumps to search word as you type.
set smartcase           " Override ignorecase when searching uppercase.
set modeline            " Enables modelines.
set modelines=5
set wildmode=longest,list:full " How to complete <Tab> matches.
"set tildeop             " Makes ~ an operator.
set virtualedit=block   " Support moving in empty space in block mode.

" Low priority for these files in tab-completion.
set suffixes+=.aux,.bbl,.blg,.dvi,.log,.pdf,.fdb_latexmk     " LaTeX
set suffixes+=.info,.out,.o,.lo

set viminfo='20,\"500

" No header when printing.
set printoptions+=header:0

scriptencoding utf-8

" =============================================================================
"                                   Styling
" =============================================================================
set background=dark     " Syntax highlighting for a dark terminal background.
set hlsearch            " Highlight search results.
set ruler               " Show the cursor position all the time.
"set showbreak=…         " Highlight non-wrapped lines.
set showcmd             " Display incomplete command in bottom right corner.

if has('gui_running')
    set columns=80
    set lines=25
    set guioptions-=T   " Remove the toolbar.
    set guifont=Monaco:h11
    "set transparency=5

    " Disable MacVim-specific Cmd/Alt key mappings.
    if has("gui_macvim")
      let macvim_skip_cmd_opt_movement = 1
    endif
else
    set t_Co=256        " We use 256 color terminal emulators these days.
endif

" Folding
if version >= 600
    set foldenable
    set foldmethod=marker
endif

" =============================================================================
"                                  Formatting
" =============================================================================
set formatoptions=tcrqn " See :h 'fo-table for a detailed explanation.
set nojoinspaces        " Don't insert two spaces when joining after [.?!].
set copyindent          " Copy the structure of existing indentation
set expandtab           " Expand tabs to spaces.
set tabstop=2           " number of spaces for a <Tab>.
"set softtabstop=2       " Number of spaces that a <Tab> counts for.
set shiftwidth=2        " Tab indention
set textwidth=79        " Text width

" Indentation Tweaks.
" e-s = do not indent if opening bracket is not first character in a line.
" g0  = do not indent C++ scope declarations.
" t0  = do not indent a function's return type declaration.
" (0  = line up with next non-white character after unclosed parentheses...
" W4  = ...but not if the last character in the line is an open parenthesis.
set cinoptions=e-s,g0,t0,(0,W4

" =============================================================================
"                                   Spelling
" =============================================================================
if has("spell")
  set spelllang=en
  set spellfile=~/.vim/spellfile.add
endif

" =============================================================================
"                               Custom Functions
" =============================================================================

function! Preserve(command)
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  execute a:command
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

" Reverse letters in a word, e.g, "foo" -> "oof".
vnoremap <silent> <Leader>r :<C-U>let old_reg_a=@a<CR>
 \:let old_reg=@"<CR>
 \gv"ay
 \:let @a=substitute(@a, '.\(.*\)\@=',
 \ '\=@a[strlen(submatch(1))]', 'g')<CR>
 \gvc<C-R>a<Esc>
 \:let @a=old_reg_a<CR>
 \:let @"=old_reg<CR>

" =============================================================================
"                                 Key Bindings
" =============================================================================

let mapleader = ','
let maplocalleader = '\'

" Clear last search highlighting
nnoremap <CR> :noh<CR><CR>

" Toggle list mode (display unprintable characters).
nnoremap <F11> :set list!<CR>

" Toggle paste mode.
set pastetoggle=<F12>

" Quicker navigation for non-wrapped lines.
vmap <D-j> gj
vmap <D-k> gk
vmap <D-4> g$
vmap <D-6> g^
vmap <D-0> g^
nmap <D-j> gj
nmap <D-k> gk
nmap <D-4> g$
nmap <D-6> g^
nmap <D-0> g^

" Remove trailing whitespace.
nmap <Leader>$ :call Preserve("%s/\\s\\+$//e")<CR>

" Indent entire file.
nmap <Leader>= :call Preserve("normal gg=G")<CR>

" Highlight text last pasted.
nnoremap <expr> <Leader>p '`[' . strpart(getregtype(), 0, 1) . '`]'

" =============================================================================
"                                    Vundle
" =============================================================================

filetype off
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

" Vim package management
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-rhubarb'
Bundle 'tpope/vim-git'
Bundle 'tpope/vim-haml'
" Markdown highlighting
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-unimpaired'
Bundle 'vim-scripts/Screen-vim---gnu-screentmux'
" Source Explorer, which finds definitions of variables in ctags-supported files
" Disabled because it requires ctags, which is annoying to install on some systems
" Bundle 'wesleyche/SrcExpl'
" File browser in vim split
Bundle 'scrooloose/nerdtree.git'
" Binds keys so that Vim and Tmux use the same navigation
Bundle 'christoomey/vim-tmux-navigator'
" Tool to search through directories for usages of a string
Plugin 'dkprice/vim-easygrep'
" Taglist, but supports javascript better
Bundle 'int3/vim-taglist-plus'
" Scala syntax highlighting support
Plugin 'derekwyatt/vim-scala'
"Typescript syntax highlighting support
Bundle 'leafgarland/typescript-vim'
" Better JS highlighting
Bundle 'pangloss/vim-javascript'
" Highlighting for terraform
Plugin 'hashivim/vim-terraform'
" Better JSX highlighting
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
" Nord theme
Plugin 'arcticicestudio/nord-vim'


if !isdirectory(expand("~/.vim/bundle/vim-fugitive"))
  BundleInstall!
  q
endif

" Solarized
let g:solarized_menu = 0
let g:solarized_termtrans = 1
let g:solarized_contrast = 'high'
let g:solarized_contrast = 'high'
let g:solarized_hitrail = 1
if !has('gui_running')
  let g:solarized_termcolors = 256
end
colorscheme nord
" colorscheme monokai
" colorscheme molokai
" colorscheme inkpot
" colorscheme delek

" LaTeX Suite: Prevents Vim 7 from setting filetype to 'plaintex'.
let g:tex_flavor = 'latex'

" Vim R plugin: do not overwrite an existing tmux.conf.
let vimrplugin_notmuxconf = 1

" Needs to be executed after Vundle.
filetype plugin indent on

" =============================================================================
"                                Filetype Stuff
" =============================================================================

if &t_Co > 2 || has('gui_running')
  syntax on
endif

" R stuff
autocmd BufNewFile,BufRead *.[rRsS] set ft=r
autocmd BufRead *.R{out,history} set ft=r

autocmd BufRead,BufNewFile *.dox      set filetype=doxygen
autocmd BufRead,BufNewFile *.mail     set filetype=mail
autocmd BufRead,BufNewFile *.bro      set filetype=bro
autocmd BufRead,BufNewFile *.ll       set filetype=llvm
autocmd BufRead,BufNewFile *.kramdown set filetype=markdown
autocmd BufRead,BufNewFile Portfile   set filetype=tcl
autocmd BufRead,BufNewFile *.es6      set filetype=javascript
autocmd BufNewFile,BufRead *.hql      set filetype=hive expandtab

" Respect (Br|D)oxygen comments.
autocmd FileType c,cpp set comments-=://
autocmd FileType c,cpp set comments+=:///
autocmd FileType c,cpp set comments+=://
autocmd FileType bro set comments-=:#
autocmd FileType bro set comments+=:##
autocmd FileType bro set comments+=:#
autocmd Filetype mail set sw=4 ts=4 tw=72
autocmd Filetype tex set iskeyword+=:

" Bro-specific coding style.
augroup BroProject
  autocmd FileType bro set noexpandtab cino='>1s,f1s,{1s'
  au BufRead,BufEnter ~/work/bro/**/*{cc,h} set noexpandtab cino='>1s,f1s,{1s'
augroup END

if has("spell")
  autocmd BufRead,BufNewFile *.dox  set spell
  autocmd Filetype mail             set spell
  autocmd Filetype tex              set spell
endif

" Prepend CTRL on Alt-key mappings: Alt-{B,C,L,I}
"autocmd Filetype tex imap <C-M-b> <Plug>Tex_MathBF
"autocmd Filetype tex imap <C-M-c> <Plug>Tex_MathCal
"autocmd Filetype tex imap <C-M-l> <Plug>Tex_LeftRight
"autocmd Filetype tex imap <C-M-i> <Plug>Tex_InsertItem

" Transparent editing of gpg encrypted files.
" By Wouter Hanegraaff <wouter@blub.net>
augroup encrypted
    autocmd!
    " First make sure nothing is written to ~/.viminfo while editing
    " an encrypted file.
    autocmd BufReadPre,FileReadPre      *.gpg set viminfo=
    " We don't want a swap file, as it writes unencrypted data to disk
    autocmd BufReadPre,FileReadPre      *.gpg set noswapfile
    " Switch to binary mode to read the encrypted file
    autocmd BufReadPre,FileReadPre      *.gpg set bin
    autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
    autocmd BufReadPost,FileReadPost    *.gpg '[,']!gpg --decrypt 2> /dev/null
    " Switch to normal mode for editing
    autocmd BufReadPost,FileReadPost    *.gpg set nobin
    autocmd BufReadPost,FileReadPost    *.gpg let &ch = ch_save|unlet ch_save
    autocmd BufReadPost,FileReadPost    *.gpg execute ":doautocmd BufReadPost " . expand("%:r")

    " Convert all text to encrypted text before writing
    autocmd BufWritePre,FileWritePre    *.gpg '[,']!gpg --default-recipient-self -ae 2>/dev/null
    " Undo the encryption so we are back in the normal text, directly
    " after the file has been written.
    autocmd BufWritePost,FileWritePost  *.gpg u
augroup END

:command NT NERDTreeToggle
:command TL TlistToggle
:command SE SrcExplToggle

" easier nav between splits
let g:BASH_Ctrl_j = 'off'
nnoremap <C-j> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h

" move up and down in wrapped lines
map j gj
map k gk

" easier tab nav
map gr gT

" shift-h and shift-l for accelerated horizontal scrolling
map H 3h
map L 3l

" Q is useless, use it for spellcheck instead
" (move to next misspelled word)
map Q ]s
" vim: set fenc=utf-8 sw=2 sts=2 foldmethod=marker :

" Mouse mode (experimental)
set mouse=a
" This enables mouse-resizable splits on OS X / tmux
set ttymouse=xterm2

" Special config for gvim on GNOME
set guifont=Monospace

" I like tabs more than buffers
" (This is `open file under cursor`)
map gf <c-w>gf

" Fix my whitespace problems
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Don't scatter swpfiles across the filesystem
set directory=$HOME/.vim/swpfiles
set backupdir=$HOME/.vim/backups
