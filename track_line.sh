#!/bin/bash
echo 'Tracking line numbers through history'
PARAMS="$*" 
LINE=$(git blame $PARAMS) 
while test $? == 0 
do 
    echo $LINE 
    COMMIT="${LINE:0:8}^" 
    LINE=$(git blame $PARAMS $COMMIT 2>/dev/null) 
done
