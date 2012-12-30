" Google App Engine projesinde miyiz, otomatik olarak belirle.
if ! exists("g:is_google_appengine")
	let g:is_google_appengine = 0
	call system("goae --check")
	let g:is_google_appengine = !v:shell_error
endif

if g:is_google_appengine
	let g:syntastic_go_checker = "goae"
else
	let g:syntastic_go_checker = "go"
endif

call SyntasticLoadChecker('go')
