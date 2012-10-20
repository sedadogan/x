" https://github.com/tpope/vim-markdown/pull/10
if has("folding")
	setlocal foldexpr=MarkdownFold()
	setlocal foldmethod=expr

	if exists('b:undo_ftplugin')
		let b:undo_ftplugin .= " foldexpr< foldmethod<"
	else
		let b:undo_ftplugin = " foldexpr< foldmethod<"
	endif

	function! MarkdownFold()
		let line = getline(v:lnum)

		" Regular headers
		let depth = match(line, '\(^#\+\)\@<=\( .*$\)\@=')
		if depth > 0
			return ">" . depth
		endif

		" Setext style headings
		let nextline = getline(v:lnum + 1)
		if (line =~ '^.\+$') && (nextline =~ '^=\+$')
			return ">1"
		endif

		if (line =~ '^.\+$') && (nextline =~ '^-\+$')
			return ">2"
		endif

		return "="
	endfunction
endif

" Folyo işleri

" TODO Bu ayarlar sadece folyolarda etkin olmalı

function! s:Compile()
	let view = winsaveview()
	update
	silent !rake compile[%]
	redraw!
	call winrestview(view)
	if v:shell_error
		echohl Error | echomsg "Compile returned error" | echohl None
	endif
endfunction

function! s:View()
	let view = winsaveview()
	update
	silent !rake view[%]
	redraw!
	call winrestview(view)
	if v:shell_error
		echohl Error | echomsg "View returned error" | echohl None
	endif
endfunction

command! -buffer FolioCompile call s:Compile()
command! -buffer FolioView call s:View()

nmap <f9> :FolioCompile<cr>
nmap <f10> :FolioCompile<cr>:FolioView<cr>

imap <f9> <esc><f9>`.i
imap <f10> <esc><f10>`.i

iab <buffer> <expr> *  <SID>DelimInsert("*", "*<Space><Space>")
iab <buffer> <expr> #  <SID>DelimInsert("#", "#<Space><Space>")
iab <buffer> <expr> ## <SID>DelimInsert("##", "##<Space>")

function! s:DelimInsert(abbr, str, ...)
	if a:0 > 0
		let pos = a:1
	else
		let pos = 1
	endif
	if col(".") != strlen(a:abbr) + pos
        	return a:abbr
	endif
	if getchar(1) == 32 " space
		return a:str
	else
		return a:abbr
	endif
endfunction

setlocal et nosta ts=8 sts=8 sw=8
