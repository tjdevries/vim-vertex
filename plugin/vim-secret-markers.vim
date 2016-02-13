" vim-secret-markers
" Maintainer:   TJ DeVries
" Version:      0.1

if exists("g:loaded_secret_markers")
  finish
endif

let g:loaded_secret_markers = 1
let g:debug_secret_markers = 0

function FindMarkers()
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
    while search('{{{', 'W') > 0
        let line_num = line('.')
        call add(start_lines, line_num)
        call add(ordered_markers, line_num)

        let fold_number = fold_number + 1
    endwhile

    goto 1
    let end_lines = []
    while search('}}}', 'W') > 0
        let line_num = line('.')
        call add(end_lines, line_num)

        while ordered_markers[ordered_index] < line_num
            let ordered_index = ordered_index + 1

            if ordered_index == len(ordered_markers)
                break
            endif
        endwhile
        call insert(ordered_markers, line_num, ordered_index)
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
        if start_lines[start_ind] < end_lines[end_ind]
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

function RemoveMarkers()
    setlocal nofoldenable

    let res = FindMarkers()
    let fold_combinations = res[0]
    let ordered_markers = res[1]

    if g:debug_secret_markers
        echo fold_combinations
        echo ordered_markers
    endif

    let g:secret_markers_file = expand('%') . '.secret_markers'

    " Send all output to the secret markers file
    execute 'redir! > ' g:secret_markers_file
    for line in ordered_markers
        echo line ':' getline(line)
        " '^^^^^' getline(line - 1) 'vvvvv' getline(line + 1)
    endfor
    " End sending output
    silent! redir END

    for line_to_delete in reverse(ordered_markers)
        exec line_to_delete . ',' . line_to_delete . 'd'
    endfor
endfunction
