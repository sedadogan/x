" Markdown Renk Özelleştirmeleri

syn clear markdownH1 markdownH2 markdownH3 markdownH4 markdownH5 markdownH6
syn region markdownH1 matchgroup=markdownHeadingDelimiter start="# *"      end="#*\s*$" keepend oneline contains=@markdownInline contained
syn region markdownH2 matchgroup=markdownHeadingDelimiter start="## *"     end="#*\s*$" keepend oneline contains=@markdownInline contained
syn region markdownH3 matchgroup=markdownHeadingDelimiter start="### *"    end="#*\s*$" keepend oneline contains=@markdownInline contained
syn region markdownH4 matchgroup=markdownHeadingDelimiter start="#### *"   end="#*\s*$" keepend oneline contains=@markdownInline contained
syn region markdownH5 matchgroup=markdownHeadingDelimiter start="##### *"  end="#*\s*$" keepend oneline contains=@markdownInline contained
syn region markdownH6 matchgroup=markdownHeadingDelimiter start="###### *" end="#*\s*$" keepend oneline contains=@markdownInline contained

syn clear markdownCodeBlock
syn region markdownCodeBlock start=" \{8,}\|\t" end="$" contained contains=markdownCodeBlockShebang
syn match markdownCodeBlockShebang "\%( \{8,}\|\t\)\%(!\|#!\)\S\+" contained

syn clear markdownListMarker
syn match markdownListMarker "\%(\t\| \{0,4\}\)[*]\%(\s\{3}\S\)\@=" contained contains=markdownItemBullet
syn match markdownListMarker "\%(\t\| \{0,4\}\)[-+]\%(\s\+\S\)\@=" contained contains=markdownItemBullet
syn match markdownItemBullet '[-*+]' contained

syn clear markdownOrderedListMarker
syn match markdownOrderedListMarker "\%(\t\| \{0,4}\)\<\d\+\.\%(\s*\S\)\@=" contained contains=markdownItemNo
syn match markdownItemNo '\d\+' contained

" Renkler
hi Pink cterm=bold gui=bold ctermfg=199 guifg=#ff0087
hi PinkReverse cterm=bold ctermbg=199 ctermfg=White guibg=#ff0087 guifg=White
hi Yellow cterm=bold gui=bold ctermfg=184 guifg=#c8bd0f
hi Blue cterm=bold gui=bold ctermfg=117 guifg=#87afff
hi Grey cterm=bold gui=bold ctermfg=250
hi Dimmed cterm=bold gui=bold ctermfg=240
hi Green cterm=bold gui=bold ctermfg=158 guifg=#2e6654

hi! def link markdownCodeBlockShebang Comment
hi! def link markdownCode Green
hi! def link markdownCodeBlock Identifier

hi! def link markdownItemBullet Blue
hi! def link markdownItemNo Blue

hi! def link markdownHeadingDelimiter Blue
hi! def link markdownH1 PinkReverse
hi! def link markdownH2 Pink

" Landslide eklentileri
syn match landslideMacro "^\.\(fx\|notes\|qr\|code\|include\|gist\|shelr\)"
syn match landslideRuler "^---\+$"
hi! def link landslideMacro Yellow
hi! def link landslideRuler Comment
