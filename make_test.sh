#!/bin/bash

debug=0
newtest=1

if [ $newtest -eq 0 ]; then
    for filename in ./test/*; do
        echo 'Testing filename ' $filename
        if [ $debug -eq 0 ]; then
            nvim -n +Vader! $filename > /dev/null && echo Success || echo Failure
        else
            nvim -n +Vader $filename
        fi
    done
else
    echo "New testing strategy"
    for filename in ./test/*; do
        echo "Testing filename " $filename
vim -Nu <(cat << VIMRC
filetype off
set rtp+=~/.config/nvim/plugged/vader.vim/
set rtp+=.
set rtp+=after
filetype plugin indent on
syntax enable
VIMRC) -c "+Vader! $filename" > /dev/null
    done
fi

# Alternative method... Not sure I want to do that yet
# nvim -nu <(cat << VIMRC
# filetype off
# set rtp+=~/.config/nvim/plugged/vader.vim
# set rtp+=.
# filetype plugin indent on
# syntax enable
# VIMRC) +'Vader! ./test/'$filename > /dev/null && echo Success || echo Failure
