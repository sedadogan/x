function! SyntaxCheckers_go_GetLocList()
    let makeprg = 'goae >/dev/null'
    let errorformat = '%f:%l:%c:%m,%f:%l%m,%-G#%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
