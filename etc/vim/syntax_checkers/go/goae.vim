" Syntastic checker for Google App Engine
" Needs the following script in your PATH
"   https://raw.github.com/roktas/x/master/bin/goae

if exists("g:loaded_syntastic_go_goae_checker")
	finish
endif
let g:loaded_syntastic_go_goae_checker = 1

function! SyntaxCheckers_go_goae_IsAvailable()
	if ! executable('goae')
		return 0
	endif

	" Check if this is a Google App Engine project
	if ! exists("g:is_google_appengine")
		let g:is_google_appengine = 0
		call system("goae --check")
		let g:is_google_appengine = !v:shell_error
	endif

	return g:is_google_appengine
endfunction

function! SyntaxCheckers_go_goae_GetLocList()
	let makeprg = 'goae 1>' . syntastic#util#DevNull()
	let errorformat = '%f:%l:%c:%m,%f:%l%m,%-G#%.%#'

	return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
	\ 'filetype': 'go',
	\ 'name': 'goae'})
