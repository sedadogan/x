syn clear markdownCodeBlock
syn region markdownCodeBlock start=" \{8,}\|\t" end="$" contained
syn region markdownCodeBlock start=" \{8,}\|\t" end="$" contained contains=markdownCodeBlockShebang
syn match markdownCodeBlockShebang "\%( \{8,}\|\t\)\%(!\|#!\)\S\+" contained

hi! def link markdownCodeBlockShebang SpecialComment
hi! def link markdownCode String
hi! def link markdownCodeBlock Identifier
hi! def link markdownListMarker Number

" Landslide extensions
syn match landslideMacro "^\.\(fx\|code\|include\|gist\)"
syn match landslideRuler "^---\+$"
hi! def link landslideMacro Character
hi! def link landslideRuler Comment
