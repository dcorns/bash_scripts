#!/bin/sh

nd='/data/Projects/node_modules/'
cwd=$(pwd)
havepackage=false
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
    pwd
    m=$(ls $2 -d)
    if [ $m = $2 ]; then
    havepackage=true
    echo $2
    echo $havepackage
    else
    npm install 2$
    m=$(ls $2 -d)
    if [ $m = $2 ]; then
    havepackage=true
    fi
    fi
    ;;
    esac
    ;;
'--save')
;;
'--save--dev')
;;

esac

if [ $havepackage = true ]; then
cd $2
ver=$(grep '"version"' package.json)
echo $ver
else
echo 'Package' $2 'not found locally or externally'
fi
cd $cwd
pkg=$(find package.json)
if [ $pkg = 'package.json' ]; then
echo "package.json exists"
else
npm init
fi

depends='"dependencies"'
if [ $3 = '-dev' ]; then
depends='"Devdependencies"'
fi
echo $depends
existingdepends=$(grep $depends package.json)
if [ $depends = $existingdepends ]; then
echo $depends 'exist'
else
declare -a pkg
readarray -t pkg < package.json
while (( ${#pkg[@]} > i )); do
    echo ${pkg[i++]}
done
fi
