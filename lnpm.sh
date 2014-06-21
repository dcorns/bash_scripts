#!/bin/sh

#set the local node modules directory here
nd='/data/Projects/node_modules/'
#set current directory
cwd=$(pwd)
havepackage=false
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
    exit
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
exit
fi
#check for package.json and npm init if it does not exist
cd $cwd
pkg=$(find package.json)
if [ $pkg = 'package.json' ]; then
echo "found package.json"
else
npm init
fi
#check for parameter 3 -dev to find out wether or not to just add as dependency or also as dev dependency
depends='"dependencies"'
if [ $3 = '-dev' ]; then
depends='"Devdependencies"'
fi
echo $depends

echo 'adding' $2 'version' $ver "to package.json"

#extract package.json lines to array
declare -a pkg
readarray -t pkg < package.json
while (( ${#pkg[@]} > i )); do
    echo ${pkg[i++]}
done


