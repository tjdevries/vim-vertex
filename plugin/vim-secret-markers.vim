" vim-secret-markers
" Maintainer:   TJ DeVries
" Version:      0.1

if exists("g:loaded_secret_markers")
  " finish
  echo "already loaded once"
endif

" Global variable definitions
let g:loaded_secret_markers = 1
let g:debug_secret_markers = 0
let g:secret_markers_file = expand('%:h') . '/._' . expand('%:t') . '.secret_markers'

let s:fold_marker_left = split(&foldmarker, ',')[0]
let s:fold_marker_right = split(&foldmarker, ',')[1]

function! FindMarkers()
    " Store line number
    let initial_pos = line('.')
    if g:debug_secret_markers
        echom 'Finding markers...'
    endif

    goto 1

    let ordered_markers = []
    let ordered_index = 0

    let start_lines = []
    let fold_number = 0
    while search(s:fold_marker_left, 'W') > 0
        let line_num = line('.')
        let line_content = ParseLine(line_num)
        let line_dict = {}
        let line_dict[line_num] = {}
        let line_dict[line_num]['content'] = line_content

        " Check if the line should be appended to the original line or not
        if getline('.') == line_content
            let line_dict[line_num]['append'] = 0
        else
            let line_dict[line_num]['append'] = 1
        endif

        call add(start_lines, line_num)
        call add(ordered_markers, line_dict)

        let fold_number = fold_number + 1
    endwhile

    goto 1
    let end_lines = []
    while search(s:fold_marker_right, 'W') > 0
        let line_num = line('.')
        let line_content = ParseLine(line_num)
        let line_dict = {}
        let line_dict[line_num] = {}
        let line_dict[line_num]['content'] = line_content

        " Check if the line should be appended to the original line or not
        if getline('.') == line_content
            let line_dict[line_num]['append'] = 0
        else
            let line_dict[line_num]['append'] = 1
        endif

        call add(end_lines, line_num)

        while keys(ordered_markers[ordered_index])[0] < line_num
            let ordered_index = ordered_index + 1

            if ordered_index == len(ordered_markers)
                break
            endif
        endwhile
        call insert(ordered_markers, line_dict, ordered_index)
    endwhile

    if g:debug_secret_markers
        echo start_lines
        echo end_lines
    endif

    goto 1

    " Connect the fold dictionaries
    let start_ind = 0
    let end_ind = 0
    let fold_combinations = {}
    let solved = 0
    while solved < fold_number
        " Check that we have a valid index still (i.e. if not, this means
        "   end_lines happen after all of the start_lines
        "   and also if start < end
        if start_ind < len(start_lines) && start_lines[start_ind] < end_lines[end_ind]
            let start_ind = start_ind + 1

            if start_ind >= len(start_lines)
                let fold_combinations[solved] = {}
                let fold_combinations[solved].start = start_lines[0]
                let fold_combinations[solved].end = end_lines[end_ind]
                let solved = solved + 1
            endif
        else
            let fold_combinations[solved] = {}
            let fold_combinations[solved].start = start_lines[start_ind - 1]
            let fold_combinations[solved].end = end_lines[end_ind]
            let solved = solved + 1

            unlet start_lines[start_ind - 1]
            let start_ind = 0
            let end_ind = end_ind + 1

        endif
    endwhile

    " initial_pos

    return [ fold_combinations, ordered_markers ]
endfunction

function! RemoveMarkers()
    setlocal nofoldenable

    let res = FindMarkers()
    let fold_combinations = res[0]
    let ordered_markers = res[1]

    if g:debug_secret_markers
        echo fold_combinations
        echo ordered_markers
    endif

    " Send all output to the secret markers file
    execute 'redir! > ' g:secret_markers_file
    silent echo 'let g:secret_markers_dict = '
        \ webapi#json#encode(ordered_markers)

    " End sending output
    silent! redir END

    " silent echo webapi#json#encode(fold_combinations)

    for line_dict in reverse(ordered_markers)
        let line_to_delete = keys(line_dict)[0]['content']
        " If we're going to delete the whole line, we don't even want it to
        " show up, so we just delete it
        if getline(line_to_delete) == line_dict[line_to_delete]['content']
            exec line_to_delete . ',' . line_to_delete . 'd'
        else
            " Otherwise, we're going to only delete from the start of our
            " comment and mark until the end of the line
            echo "Not the same line " . line_to_delete
            exec line_to_delete . ',' . line_to_delete . 's/' . line_dict[line_to_delete]['content'] . '//'
        endif
    endfor
endfunction

function! GetMarkersFromSecretFile()
    " This function sets the g:secret_markers_dict variable
    "   Format: [ {line_num: {'content': line_contents, 'append': 0/1}}, {line_num: {'content': line_contents, 'append': 0/1}}, ... ]
    setlocal nofoldenable

    exec "source " . g:secret_markers_file
    if g:debug_secret_markers
        echo g:secret_markers_dict
    endif
endfunction

function! InsertMarkersFromDict()
    " This function will insert the lines back into the file
    "   It calls GetMarkersFromSecretFile first to set the
    "       g:secret_markers_dict
    "   Then inserts them into the file!
    call GetMarkersFromSecretFile()

    for line_dict in g:secret_markers_dict
        " Get the line number that we're going to insert our fold on
        let line_num = keys(line_dict)[0]

        " Make sure that if the folds are at the end of the file, we can still
        " get to them:
        let max_line = line('$')
        while max_line < line_num
            " Open a new line at the bottom of the file
            normal Go
            let max_line = line('$')
        endwhile

        " Insert at the beginning of the line, and then add a return character
        if line_dict[line_num]['append']
            execute line_num . ',' . line_num . 's/$/' . line_dict[line_num]['content'] . '/'
        else
            execute line_num . ',' . line_num . 's/^/' . line_dict[line_num]['content'] . '\r/'
        endif
    endfor
endfunction

function! ParseLine(line_num)
    " This function returns a string of what should be removed from the line
    " Returns:
    "   Empty string ('') - There was nothing in the line that matched a fold marker
    "   Entire line       - If the whole line consists purely of a comment +
    "                       fold_marker, then the entire line will be return
    "   Subset of line    - Whitespace before comment through end of line (not
    "                       including the line ending)
    set magic

    let current_line = getline(a:line_num)

    " If there are no fold in the current line, return an empty string
    if current_line !~ s:fold_marker_right && current_line !~ s:fold_marker_left
        return ''
    endif

    if exists("&commentstring")
        " echo &commentstring
        let [l, r] = Surroundings()

        " TODO: Improve this searching?
        let commentstart = match(getline(a:line_num), l)
        if commentstart < 0
            let commentstart = 0
        endif

        execute "let return_line = current_line[" . commentstart . ":]"
        if g:debug_secret_markers
            echom 'Parsing line: `' . getline(a:line_num) . '`'
            echom ' l, r: [' . l . ', ' .  r . ']'
            echom ' commentstart -> ' . commentstart
            echom ' return_line (' . a:line_num . '): `' . return_line . '`'
        endif

        " If there is only white space in front of our return_line,
        "   then we can just return the whole line
        " Else, we just want to return from the comment onwards
        if current_line =~ '^\s*' . return_line
            if g:debug_secret_markers
                echom ' line: ' . a:line_num . ' has only whitespace in front'
            endif

            return current_line
        else
            if g:debug_secret_markers
                echom ' line: ' . a:line_num . ' has some text in front of it'
            endif

            return return_line
        endif
    else
        " If I don't know what a comment is, then I can't differentiate
        " between where the comment starts and anything else.
        return getline(a:line_num)
    endif
endfunction

function! Surroundings() abort
  return split(get(b:, 'commentary_format', substitute(substitute(
        \ &commentstring, '\S\zs%s',' %s','') ,'%s\ze\S', '%s ', '')), '%s', 1)
endfunction

" vim: set foldlevel=4:
