#!/bin/sh
clear
#set the local node modules directory here
nd='/data/Projects/node_modules/'

#******************************************Major Functions**********************************************************
#Configure existing directory that already contains normal node modules to work with lnpm
setupDirs(){
#Rename each directory with a 0-0-0 extention for version identification
    #Proccess directories
    cd $nd
    for path in $nd*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    dirname="$(basename "${path}")"
    cd $dirname
    ver=$(grep '"version"' package.json)
vers=${ver#*:} #remove everything left of the colon
ver=${vers%*,} #drop the comma
    newdir=$dirname$ver
    cd ..
    echo $newdir
    mv $dirname "$newdir"
done

echo "Setup Directories"
exit 0
}


#validate input
case $1 in
    'install') ;;
    'update') ;;
    'configure') setupDirs ;;
    *) echo 'The first parameter must be install, configure or update'
       exit 0
       ;;
esac

case $3 in
    '-dev') ;;
    '') ;;
    *) echo 'The third parameter must be -dev or null'
       exit 0
       ;;
esac

#break down install and update
if [ "$1" = 'update' ]; then
    if [ "$2" = '' ]; then
        echo 'update all chosen: This could take a while. To avoid this include a package to update as the second parameter'
        echo "Enter 'yes' to continue"
        read
        if [ "$REPLY" = 'yes' ]; then
            echo 'Polling latest local versions'
            #Create temp directory for module proccessing
            cd $nd
            mkdir incoming_modules
            cd incoming_modules
            cd ..
            rm incoming_modules -R
        else
            echo 'user canceled'
            exit 0
        fi
    else
        echo 'module included'
    fi
else
#*************************************lnpm install code******************************************************
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
alreadydep=false

checkobject(){
    #Check package for dependencies and devdependencies objects
    checkdep=$(grep '"dependencies"' package.json)
    checkdep=${checkdep:0:14}
    if [ "$checkdep" = '"dependencies"' ]; then
        havedependencies=true
    fi
    checkdep=$(grep '"devDependencies"' package.json)
    checkdep=${checkdep:0:17}
    if [ "$checkdep" = '"devdependencies"' ]; then
        havedevdependencies=true
    fi;
}
#check for package.json and npm init if it does not exist
cd $cwd
pkg=$(find package.json)
if [ "$pkg" = 'package.json' ]; then
    echo "found package.json"
    #see if package is already installed
    installpackage=$(grep $nd$2 package.json)
    installpackage=${installpackage:0:ndlength+=pkglength}
    if [ "$installpackage" = "$nd$2" ]; then
        alreadydep=true
        if [ "$3" = '-dev' ]; then
            #check for devDependencies in package.json
            devDependencies=$(grep '"devDependencies"' -o package.json)
                #check return code of grep, if 0 devDependencies does exist
            if [ $? = 0 ]; then
                #check devDependencies for module $nd$2
                    #extract devDependencies from package.json and store in devtmp
                declare -a devpkg
                devstart=false
                readarray -t devpkg < package.json
                touch devtmp
                while (( ${#devpkg[@]} > i )); do
                    pkgline=${devpkg[i++]}
                        #check each package.json line for devDependencies text
                    devdep=$(echo $pkgline | grep -o 'devDependencies')
                            #when devDependencies is found start copying lines to devtmp
                    if [ "$devdep" = 'devDependencies' ]; then
                        devstart=true
                    fi
                    if [ $devstart = true ]; then
                        echo $pkgline >> devtmp
                        pkglinetest=$(echo grep $pkgline | grep -o '}')
                        #when closing bracket is found, stop copying lines
                        if [ "$pkglinetest" = '}' ]; then
                            devstart=false
                        fi
                    fi
                done
                    #check resulting file(which should contain all devDependencies modules) for $nd$2
                devtest=$(grep -o $nd$2 devtmp)
                if [ $? = 0 ]; then
                    echo $2 'already installed'
                    rm devtmp
                    exit 0
                fi

            fi
            exit 0
            if [ "$devDependencies" = "$nd$2" ]; then
                echo $2 'already installed'
                exit 0
            fi
        else
            echo $2 'already installed'
            exit 0
        fi
        #check installed version against stored version offer change if not matched
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




echo 'adding' $2 'version' $ver "to package.json"
cd $cwd
#extract package.json lines to array
declare -a pkg
touch package.njson
readarray -t pkg < package.json
if [ $alreadydep = false ]; then
    if [ $havedependencies = true ]; then
        echo 'Executing only one dependency'
        while (( ${#pkg[@]} > i )); do
            pkgline=${pkg[i++]}
            echo $pkgline >> package.njson
            dep=$(echo $pkgline | grep -o 'dependencies')
            #if the result is invalid the if statement will generate error however program still executes as expected
            if [ "$dep" = 'dependencies' ]; then
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
fi
#check for parameter 3 -dev add as a dependency also
if [ $3 = '-dev' ]; then
depends='"devDependencies"'
if [ $havedevdependencies = true ]; then
    echo 'Executing only one devDependency'
    while (( ${#pkg[@]} > i )); do
        pkgline=${pkg[i++]}
        echo $pkgline >> package.njson
        dep=$(echo $pkgline | grep -o 'devDependencies')
        #if the result is invalid the if statement will generate error however program still executes as expected
        if [ "$dep" = 'devDependencies' ]; then
            echo $nd$2":" $ver"," >> package.njson
        fi
    done
else
    echo 'executing add devDependency structure'
    size=${#pkg[@]}
    let size-=1
    count=1
    while (( ${#pkg[@]} > i )); do
        pkgline=${pkg[i++]}
        echo $pkgline >> package.njson
        dep=$(echo $pkgline | grep -o 'devDependencies')
        #if the result is invalid the if statement will generate error however program still executes as expected
        if [ $size = $count ]; then
            depends='"devDependencies"'
            echo $depends': {' >> package.njson
            echo $nd$2 ":" $ver >> package.njson
            echo "}" >> package.njson
        fi
        let count+=1
    done
fi
fi
#replace package.json with modified
rm package.json
mv package.njson package.json
#************************************************END lnpm install code****************************************
fi