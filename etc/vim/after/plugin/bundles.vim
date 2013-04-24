" Eklenti tercihleri

" Bazı eklentiler kullanıcı tercihlerini yüklenmeden sonra alıyor.  Bu tür
" eklentilerin kullanıcı tercihlerini bu dosyada tutuyoruz.  DİKKAT!  Önce
" eklentinin varlığını denetlemelisiniz.  Aksi halde hata olacaktır.

" Bu dizin ve üstünde bir inşa dosyaları var mı?
function! s:has_buildfiles(...)
	let buildfiles = (a:0 != "" ? a:0 : ["Makefile", "Makefile.am", "Makefile.in", "GNUmakefile"])
	for f in buildfiles
		let found = findfile(f, escape(expand("%:p:h"), ' ~|!"$%&()=?{[]}+*#'."'") . ";")
		" Ev dizinindeki çöp dosyaları dikkate alma.
		if found != "" && found != $HOME . "/" . f
			return 1
		endif
	endfor
	return 0
endfunction

" Go geliştirme ortamı bilgilerini topla
function! s:goinfo()
	for ext in [6, 8, 5]
		let compiler = ext . 'g'
		if executable(compiler)
			return { 'ext': ext, 'compiler': compiler, 'linker': ext . 'l' }
		endif
	endfor
	return {}
endfunction

" Go için ön hazırlık.
if !exists('s:goinfo')
	let s:goinfo = s:goinfo()
endif

if exists("g:loaded_syntastic_plugin")
	sign define SyntasticError text=―▶ texthl=Search
	sign define SyntasticWarning text=>> texthl=Warning
	let g:syntastic_enable_signs = 1
	set statusline+=%#warningmsg#
	set statusline+=%{SyntasticStatuslineFlag()}
	set statusline+=%*

	" Ruby'de rubocop denetimi istiyoruz.
	let g:syntastic_ruby_checkers = ['mri', 'rubocop']

	" Statik tipli bazı dillerde geliştirilen projelerde Syntastic
	" eklentisini etkisizleştir, aksi halde (önceden derlenmesi gereken
	" kaynak dosyaların varlığından dolayı) gürültü oluyor.
	function! s:disable_syntastic_on_c_projects()
		if s:has_buildfiles()
			" FIXME Toggle yerine doğrudan disable et
			SyntasticToggleMode
		endif
	endfunction
	autocmd FileType c,cpp call s:disable_syntastic_on_c_projects()

	" Açık olarak belirtilmiş bash betiklerinde Bashism denetimi yapma.
	function! s:disable_checkbashisms_checker()
		let shebang = syntastic#util#parseShebang()
		if match(shebang['exe'], 'bash') != -1
			let g:syntastic_sh_checkers = ['sh']
		endif
	endfunction
	au FileType sh call s:disable_checkbashisms_checker()

	" Bashism denetiminde çok kısıtlayıcı olma
	let g:syntastic_sh_checkbashisms_args="-x"
endif

if exists("g:loaded_SingleCompile")
	if !empty(s:goinfo)
		if has('unix')
			call SingleCompile#SetTemplate('go', 'command', s:goinfo['compiler'])
			call SingleCompile#SetTemplate('go', 'run', 'clear; ' . s:goinfo['linker'] . ' -o %< %<.' . s:goinfo['ext'] . ' && ./%<')
		endif
	endif

	function! MakeOrSingleCompile()
		if s:has_buildfiles()
			make
		else
			SCCompile
		endif
	endfunction

	function! MakeRunOrSingleCompileRun()
		if s:has_buildfiles()
			let prog = expand("%<")
			lmake
			if filereadable(prog)
				execute '!clear && ./' . prog
			endif
		else
			SCCompileRun
		endif
	endfunction

	if ! hasmapto("<F9>")
		nmap <F9> :call MakeOrSingleCompile()<cr>
	endif
	if ! hasmapto("<F10>")
		nmap <F10> :call MakeRunOrSingleCompileRun()<cr>
	endif
endif

if exists("g:loaded_yaifa")
	function! s:unload_yaifa_on_blank_files()
		let i = 1
		while i <= 10
			if getline(i) =~ '\S'
				return
			endif
			let i += 1
		endwhile
		au! YAIFA
	endfunction
	au FileType * call s:unload_yaifa_on_blank_files()
endif

if exists("colors_name") && colors_name == "tir_black"
	hi StatusLineNC guifg=black guibg=#202020 ctermfg=234 ctermbg=245
endif

if exists('g:loaded_taglist')
	nnoremap <silent> <F8> :TlistToggle<CR>
	let tlist_go_settings = 'go;p:Packages;t:Types;f:Functions;c:Constants;v:Variables'
else
	" aksi halde tagbar
	let g:tagbar_type_coffee = {
		\ 'kinds' : [
		\   'f:functions',
		\   'o:object'
		\ ],
		\ 'kind2scope' : {
		\  'f' : 'object',
		\   'o' : 'object'
		\},
		\ 'sro' : ".",
		\ 'ctagsbin' : 'coffeetags',
		\ 'ctagsargs' : '--include-vars',
		\}
	let g:tagbar_type_go = {
		\ 'kinds' : [
		\   'p:packages',
		\   't:types',
		\   'f:functions',
		\   'c:constants',
		\   'v:variables'
		\ ]
		\}
endif
