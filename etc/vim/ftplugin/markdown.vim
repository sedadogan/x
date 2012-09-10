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
