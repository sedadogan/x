" Google App Engine projelerinde Syntastic denetimi için localvimrc
" eklentisinin kurulu olmasını sağlayın ve proje kökünde '.lvimrc' adında
" aşağıdaki içerikte bir dosya oluşturun:
"
"	let g:is_google_appengine = 1
if exists("g:is_google_appengine") && g:is_google_appengine
    let s:supported_checkers = ["goae", "go", "6g", "gofmt"]
else
    let s:supported_checkers = ["go", "6g", "gofmt"]
endif
call SyntasticLoadChecker(s:supported_checkers, 'go')
