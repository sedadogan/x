" Google App Engine projesinde miyiz, otomatik olarak belirle.
if ! exists("g:is_google_appengine")
	let g:is_google_appengine = 0
	if system("xxgoae --check")
		let g:is_google_appengine = !v:shell_error
	endif
endif

if g:is_google_appengine
	let s:supported_checkers = ["goae", "go", "6g", "gofmt"]
else
	let s:supported_checkers = ["go", "6g", "gofmt"]
endif

call SyntasticLoadChecker(s:supported_checkers, 'go')
