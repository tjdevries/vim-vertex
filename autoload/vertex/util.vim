
" {{{ get fold_markers
" {{{ get_left_fold_marker
function! vertex#util#get_left_fold_marker()
    return split(&foldmarker, ',')[0]
endfunction
" }}}

" {{{ get_right_fold_marker
function! vertex#util#get_right_fold_marker()
    return split(&foldmarker, ',')[1]
endfunction
" }}}
" }}}

" {{{ set_markers_file
" Set the buffer local file location
function! vertex#util#set_markers_file() abort
    return expand('%:h') . '/._' . expand('%:t') . '.secret_markers'
endfunction
" }}}

" {{{ vertex#strip
function! vertex#util#strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction
" }}}

" {{{ surroundings
"   From tpope. Maybe this will get changed eventually?
function! vertex#util#surroundings() abort
  return split(get(b:, 'commentary_format', substitute(substitute(
        \ &commentstring, '\S\zs%s',' %s','') ,'%s\ze\S', '%s ', '')), '%s', 1)
endfunction
" }}}
