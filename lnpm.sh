#!/bin/sh

#set the local node modules directory here
nd='/data/Projects/node_modules/'
ndlength=${#nd}
pkglength=${#2}
#set current directory
cwd=$(pwd)
havepackage=false
packageinstalled=false
devpackageinstalled=false
havedependencies=false
havedevdependencies=false
isdevdependency=false

checkobject(){
    #Check package for dependencies and devdependencies objects
    checkdep=$(grep '"dependencies"' package.json)
    checkdep=${checkdep:0:14}
    if [ $checkdep = '"dependencies"' ]; then
        havedependencies=true
    fi
    checkdep=$(grep '"devdependencies"' package.json)
    checkdep=${checkdep:0:17}
    if [ $checkdep = '"devdependencies"' ]; then
        havedevdependencies=true
    fi;
}
#check for package.json and npm init if it does not exist
cd $cwd
pkg=$(find package.json)
if [ $pkg = 'package.json' ]; then
    echo "found package.json"
    #see if package is already installed
    installpackage=$(grep $nd$2 package.json)
    installpackage=${installpackage:0:ndlength+=pkglength}
    if [ $installpackage = $nd$2 ]; then
        echo $2 'already installed'
        #check if installed as devdependency or just dependency, and if dev flag set handle devdependency
        #check installed version against stored version offer change if not matched
        exit 0
    fi
else
npm init
fi
checkobject

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


#check for parameter 3 -dev to find out wether or not to just add as dependency or also as dev dependency
depends='"dependencies"'
if [ $3 = '-dev' ]; then
isdevdependency=true
fi

echo 'adding' $2 'version' $ver "to package.json"
cd $cwd
#extract package.json lines to array
declare -a pkg
touch package.njson
readarray -t pkg < package.json

if [ $havedependencies = true ]; then
    echo 'Executing only one dependency'
    while (( ${#pkg[@]} > i )); do
        pkgline=${pkg[i++]}
        echo $pkgline >> package.njson
        dep=$(echo $pkgline | grep -o 'dependencies')
        #if the result is invalid the if statement will generate error however program still executes as expected
        if [ $dep = 'dependencies' ]; then
            echo $nd$2":" $ver"," >> package.njson
        fi
    done
else
    echo 'executing add dependency structure'
    size=${#pkg[@]}
    let size-=1
    count=1
    while (( ${#pkg[@]} > i )); do
        pkgline=${pkg[i++]}
        echo $pkgline >> package.njson
        dep=$(echo $pkgline | grep -o 'dependencies')
        #if the result is invalid the if statement will generate error however program still executes as expected
        if [ $size = $count ]; then
            depends='"dependencies"'
            echo $depends': {' >> package.njson
            echo $nd$2 ":" $ver >> package.njson
            echo "}" >> package.njson
        fi
        let count+=1
    done
fi

#replace package.json with modified
rm package.json
mv package.njson package.json
