" Eklenti tercihleri

" Bazı eklentiler kullanıcı tercihlerini yüklenme anındaki alıyor.  Bu
" tür eklentilerin kullanıcı tercihlerini bu dosyada tutuyoruz.

" Netrw tarihçe ve yerler dosyaları nereye yazılsın?
let g:netrw_home=$HOME

" Align eklentisinin kendine özel menü almasını engelle
let g:DrChipTopLvlMenu="Plugin."

" SuperTab eklentisinde kullanılan sekme tuşu Snipmate ile çakışıyor.
let g:SuperTabMappingForward  = '<c-down>'
let g:SuperTabMappingBackward = '<c-up>'

" Exuberant-ctags paketi kurulu olmayabilir, taglist eklentisini sustur.
if !executable('ctags')
	let loaded_taglist = 'yes'
endif

" Localvimrc'nin onay istemesini engelle.
let g:localvimrc_sandbox = 0
let g:localvimrc_ask = 0

" Pad eklentisi şikayet etmesin. Bu ayarı daha sonra local.vim'de
" değiştirebiliriz.
let g:pad_dir = $HOME
