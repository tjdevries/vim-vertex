
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

" {{{ combine_ordered_lists
function! vertex#util#combine_ordered_lists(first, second) abort
    let ordered = []

    let i1 = 0
    let i2 = 0
    let len1 = len(a:first)
    let len2 = len(a:second)

    while i1 < len1 || i2 < len2
        let current_obj = {}
        let line_1 = vertex#util#get_line_num(a:first, i1)
        let line_2 = vertex#util#get_line_num(a:second, i2)

        if  line_1 < line_2
            let current_obj = a:first[i1]
            let i1 = i1 + 1
        else
            let current_obj = a:second[i2]
            let i2 = i2 + 1
        endif

        call add(ordered, current_obj)
    endwhile

    return ordered
endfunction
" }}}

" {{{ get_line_num
function! vertex#util#get_line_num(list, index) abort
    if a:index >= len(a:list)
        " TODO: Is this big enough? xD
        return 99999
    else
        return keys(a:list[a:index])[0]
    endif
endfunction
" }}}
