let g:is_bash=1
autocmd BufNewFile,BufRead $HOME/\(*/\|\)etc/*
      \ if &ft =~# '^\%(conf\|modula2\)$' |
      \   set ft=sh |
      \ elseif &ft == '' |
      \   setf sh |
      \ endif
