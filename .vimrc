" =============================================================================
"                               General settings
" =============================================================================
set nocompatible        " iMproved.

" Plugins
filetype off
" To get Vundle, run `git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim`
" Then :PluginInstall afterwards to install these
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'christoomey/vim-tmux-navigator'
call vundle#end()
filetype plugin indent on

set autoindent          " Copy indent from current line on starting a new line.
set backspace=indent,eol,start " Backspacing over everything in insert mode.
set hidden              " Allow for putting dirty buffers in background.
set history=1024        " Lines of command history
set ignorecase          " Case-insensitive search
set incsearch           " Jumps to search word as you type.
set smartcase           " Override ignorecase when searching uppercase.
set wildmode=longest,list:full " How to complete <Tab> matches.
set virtualedit=block   " Support moving in empty space in block mode.

" Low priority for these files in tab-completion.
set suffixes+=.aux,.bbl,.blg,.dvi,.log,.pdf,.fdb_latexmk     " LaTeX
set suffixes+=.info,.out,.o,.lo

set viminfo='20,\"500

scriptencoding utf-8

" =============================================================================
"                                   Styling
" =============================================================================
set background=dark     " Syntax highlighting for a dark terminal background.
set hlsearch            " Highlight search results.
set ruler               " Show the cursor position all the time.
set showcmd             " Display incomplete command in bottom right corner.

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
set tabstop=4           " number of spaces for a <Tab>.
set shiftwidth=4        " Tab indention
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
"                                 Key Bindings
" =============================================================================

" Clear last search highlighting
nnoremap <CR> :noh<CR><CR>

" Toggle list mode (display unprintable characters).
nnoremap <F11> :set list!<CR>

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

colorscheme nord
" colorscheme monokai
" colorscheme molokai
" colorscheme inkpot
" colorscheme delek

" =============================================================================
"                                Filetype Stuff
" =============================================================================

syntax on


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
" In tmux/modern terminals, use SGR mouse reporting.
if exists('&ttymouse')
  set ttymouse=sgr
endif

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
