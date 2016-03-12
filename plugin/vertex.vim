" vim-secret-markers
" Maintainer:   TJ DeVries
" Version:      0.1

if exists("g:loaded_secret_markers")
    if g:debug_secret_markers == 0
        echom "Not loading again"
        finish
    endif
endif

" Global variable definitions
let g:loaded_secret_markers = 1
let g:debug_secret_markers = 0

" {{{ Primary Functions

command -bar VertexRemove call vertex#remove_markers()
command -bar VertexInsert call vertex#insert_markers()

" vim: set foldlevel=4:
