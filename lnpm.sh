#!/bin/sh

#set the local node modules directory here
nd='/data/Projects/node_modules/'
#set current directory
cwd=$(pwd)
havepackage=false
havedependencies=false
havedevdependencies=false
isdevdependency=false
#see if the package exists in the local directory
cd $nd
m=$(ls $2 -d)
if [ $m = $2 ]; then
  havepackage=true
  echo 'package found in local directory' $nd
#not in local directory, download it if it exists
else
  npm install 2$
  m=$(ls $2 -d)
  if [ $m = $2 ]; then
    havepackage=true
  else
    echo 'package does not exist in directory or in registry'
    exit 0
    fi
    fi
#if the package exists, get the version
if [ $havepackage = true ]; then
cd $2
ver=$(grep '"version"' package.json)
vers=${ver#*:}
ver=${vers%*,}
else
echo 'Package' $2 'not found locally or externally'
exit 0
fi
#check for package.json and npm init if it does not exist
cd $cwd
pkg=$(find package.json)
if [ $pkg = 'package.json' ]; then
echo "found package.json"
else
npm init
fi
#Check package for dependencies and devdependencies objects
checkdep=$(grep '"dependencies"' package.json)
if [ $checkdep = '"dependencies"' ]; then
havedependencies=true
fi
checkdep=$(grep '"devdependencies"' package.json)
if [ $checkdep = '"devdependencies"' ]; then
havedevdependencies=true
fi
#check for parameter 3 -dev to find out wether or not to just add as dependency or also as dev dependency
depends='"dependencies"'
if [ $3 = '-dev' ]; then
isdevdependency=true
fi

echo 'adding' $2 'version' $ver "to package.json"

#extract package.json lines to array
declare -a pkg
touch package.njson
readarray -t pkg < package.json
if [ $havedependendies = true ]; then
    while (( ${#pkg[@]} > i )); do
        pkgline=${pkg[i++]}
        echo $pkgline >> package.njson
        dep=$(echo $pkgline | grep -o 'dependencies')
        #if the result is invalid the if statement will generate error however program still executes as expected
        if [ $dep = 'dependencies' ]; then
            echo $nd$2":~"$ver"," >> package.njson
        fi
    done
else
    size=${#pkg[@]}
    echo $size
    count=1
    while (( ${#pkg[@]} > i )); do
        pkgline=${pkg[i++]}
        echo $pkgline >> package.njson
        dep=$(echo $pkgline | grep -o 'dependencies')
        #if the result is invalid the if statement will generate error however program still executes as expected
        if [ $size-2 = $count ]; then
            depends='"dependencies"'
            echo $depends '{' >> package.njson
            echo $nd$2":~"$ver >> package.njson
            echo "}" >> package.njson
        fi
        let count+=1
        echo $count
    done
fi