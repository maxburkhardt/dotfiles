" Respect Doxygen comments.
au FileType c,cpp set comments-=://
au FileType c,cpp set comments+=:///
au FileType c,cpp set comments+=://

" Custom file types
au BufRead,BufNewFile *.dox     set filetype=doxygen spell
au BufRead,BufNewFile *.mail    set filetype=mail spell
au BufRead,BufNewFile *.bro     set filetype=bro
au BufRead,BufNewFile *.wiki    set filetype=mediawiki spell
au BufRead,BufNewFile *.ll      set filetype=llvm
au BufRead,BufNewFile *.td      set filetype=tablegen
au BufRead,BufNewFile Portfile  set filetype=tcl

" Autocmds to automatically enter hex mode and handle file writes properly
" vim -b : edit binary using xxd-format!
augroup Binary
au!
au BufReadPre *.bin,*.hex setlocal binary
au BufReadPost *
      \ if &binary | Hexmode | endif
au BufWritePre *
      \ if exists("b:editHex") && b:editHex && &binary |
      \  let oldro=&ro | let &ro=0 |
      \  let oldma=&ma | let &ma=1 |
      \  exe "%!xxd -r" |
      \  let &ma=oldma | let &ro=oldro |
      \  unlet oldma | unlet oldro |
      \ endif
au BufWritePost *
      \ if exists("b:editHex") && b:editHex && &binary |
      \  let oldro=&ro | let &ro=0 |
      \  let oldma=&ma | let &ma=1 |
      \  exe "%!xxd" |
      \  exe "set nomod" |
      \  let &ma=oldma | let &ro=oldro |
      \  unlet oldma | unlet oldro |
      \ endif
augroup END

" Transparent editing of gpg encrypted files.
" By Wouter Hanegraaff <wouter@blub.net>
augroup encrypted
    au!
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
