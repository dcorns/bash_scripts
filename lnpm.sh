#!/bin/sh

nd='/data/Projects/node_modules/'

case $1 in
'install')
    case $2 in
    '--save')
    echo '--save'
    ;;
    '--save-dev')
    echo '--save-dev'
    ;;
    *)
    cd $nd
    m=$(ls $2 -d)
    if [ $m = $2 ]; then
    echo $2
    else
    echo 'no match'
    fi
    ;;
    esac
    ;;
'--save')
;;
'--save--dev')
;;

esac