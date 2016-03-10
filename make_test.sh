#!/bin/bash

for filename in ./test/*; do
    echo 'Testing filename ' $filename
    nvim -n +Vader! $filename > /dev/null  && echo Success || echo Failure
    # nvim -nu <(cat << VIMRC
# filetype off
# set rtp+=~/.config/nvim/plugged/vader.vim
# set rtp+=.
# filetype plugin indent on
# syntax enable
# VIMRC) +'Vader! ./test/'$filename > /dev/null && echo Success || echo Failure
done
