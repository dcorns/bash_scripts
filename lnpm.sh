#!/bin/sh
#Created by Dale Corns codefellow@gmail.com 2014
clear
#*******************************************Variables*******************************************************************
#set the local node modules directory here
nd='/data/Projects/node_modules/'
#define colors
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[1;33m'
default='\e[0m'
havedependencies=false
havedevdependencies=false
cwd=$(pwd)
#******************************************Functions********************************************************************
#++++++++++++++++++++++++++++++++++++++++++++++++++++checkobject++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#Find out if package.json has dependencies and devdependencies section
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

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++setupDirs++++++++++++++++++++++++++++++++++++++++++++++
#Configure existing directory that already contains normal node modules to work with lnpm
setupDirs(){
#Rename each directory with a 0-0-0 extention for version identification
    #Proccess directories
    cd $nd
    for path in $nd*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    dirname="$(basename "${path}")"

    cd "$dirname"
    ver=$(grep '"version"' package.json)
    pkgname=$(grep '"_id"' package.json)
    pkgnm=${pkgname#*:} #remove everything left of the colon
    pknm=${pkgnm%*,}
    pknmlength=${#pknm}
    charvalid=true
    count=1
    pknam=''
    #extract everything left of the @ to retrieve package name
    while (( count < $pknmlength )); do
    testval=${pknm:count:1}
    if [ $testval == "@" ]; then
    charvalid=false
    fi
    if [ $charvalid = true ]; then
    pknam=$pknam${pknm:count:1}
    fi
    let count+=1
    done
    pknam=${pknam:1:${#pknam}-1}
    #extract from version field to retrieve version number
    vers=${ver#*:} #remove everything left of the colon
    ver=${vers%*,} #drop the comma
    newdir=$pknam$ver
    cd ..
    #if the directory does not have a version number with name add it here otherwise leave alone
    if [ "$newdir" != "$dirname" ]; then
        mv $dirname "$newdir"
        echo -e ${green}'Converted' $dirname 'to' $newdir${default}
    else
        echo -e ${yellow}$dirname 'already prepared, nothing to do.'${default}
    fi
done
exit 0
}

#++++++++++++++++++++++++++++++++++++++++++++++++++update+++++++++++++++++++++++++++++++++++++++++++++++++++++++
#add latest packages from npm registry to local directory
update(){
cd $nd
#Create a temp directory and copy all modules over, striping them their version from directory name
#Run npm install
#Configure the temp directories and copy what does not already exist to the local folder, then remove temp directory and contents
if [ "$2" = '' ]; then
echo -e ${yellow}'update all chosen: This could take a while. To avoid this include a package to update as the second parameter'${default}
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
            echo -e ${red}'user canceled'${default}
            exit 0
        fi
    else
        echo -e ${yellow}'module included'${default}
    fi

}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++revertDirs+++++++++++++++++++++++++++++++++++++++++++++++++++
#revert the local folder or some other folder to standard package names
revertDirs(){
cd $nd
echo -e ${yellow}'Reverting local node package directories will break all projects relying on lnpm'${default}
echo -e ${yellow}'Make sure to remove the path from each package entry in package.json and run npm install'${default}
echo -e ${yellow}'in the projects directory for each lnpm project you wish to make an npm'${default}
echo -e ${yellow}'Since lnpm allows you to store multiple package versions by adding the version number to the'${default}
echo -e ${yellow}'directory name (normally just package name), this proccess will put each older version in'${default}
echo -e ${yellow}'a directory called <packagename>1...10 respectively. The latesest version will be in <packagename>'${default}
echo -e ${yellow}'Enter yes to continue'${default}
read
if [ "$REPLY" != 'yes' ]; then
    exit 0
fi
dircount=0
for path in $nd*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    dirname="$(basename "${path}")"

    cd "$dirname"
    #remove everything in directory name from space to end
    revdir=${dirname%%'"'*} #remove everything right of first "
    #remove trailing space leaving only the package name
    revdirlength=${#revdir}
    revdir=${revdir:0:revdirlength-1}
    #store new directory names in array for duplicate proccessing
    echo $revdir
    dups=0
    for i in ${adir[@]};do
    #echo ${i} , $revdir
    if [ ${i} = $revdir ]; then
        let dups=dups+1
        echo $dups
        revdir=$revdir$dups
    fi
    #echo ${i} , $dups
    done
    adir[$dircount]=$revdir
    cd ..
    let dircount=dircount+1
done
#adir[$dircount]=mongodb
echo ${adir[*]}

exit 0
}

#+++++++++++++++++++++++++++++++++++++++++++++++preDeploy+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#copy packages to project directory revert directory names and update package.json for deployment
preDeploy(){
echo 'preDeploy'
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++install++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#*************************************lnpm install code*****************************************************************
install(){
ndlength=${#nd}
pkglength=${#2}
#set current directory
havepackage=false
packageinstalled=false
devpackageinstalled=false
isdevdependency=false
alreadydep=false

#check for package.json and npm init if it does not exist
cd $cwd
pkg=$(find package.json)
if [ "$pkg" = 'package.json' ]; then
    echo -e ${green}"found package.json"${default}
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
                    echo -e ${yellow}$2 'already installed'${default}
                    rm devtmp
                    exit 0
                fi

            fi
            exit 0
            if [ "$devDependencies" = "$nd$2" ]; then
                echo -e ${yellow}$2 'already installed'${default}
                exit 0
            fi
        else
            echo -e ${yellow}$2 'already installed'${default}
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
  echo -e ${green}'package found in local directory' $nd${default}
#not in local directory, download it if it exists
else
  npm install 2$
  m=$(ls $2 -d)
  if [ $m = $2 ]; then
    havepackage=true
  else
    echo -e ${red}'package does not exist in directory or in registry'${default}
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
echo -e ${red}'Package' $2 'not found locally or externally'${default}
exit 0
fi

echo -e ${green}'adding' $2 'version' $ver "to package.json"${default}
cd $cwd
#extract package.json lines to array
declare -a pkg
touch package.njson
readarray -t pkg < package.json
if [ $alreadydep = false ]; then
    if [ $havedependencies = true ]; then
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
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++check3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#validate the third parameter
check3(){
case $3 in
    '-dev') ;;
    '') ;;
    *) echo -e ${red}'The third parameter must be -dev or null'${default}
       exit 0
       ;;
esac
}

#/////////////////////////////////////////////////SCRIPT START//////////////////////////////////////////////////////////
#validate input
case $1 in
    'install')
        check3
        install
        exit 0
     ;;
    'update')
        update
        exit 0
    ;;
    'configure')
        setupDirs
        exit 0
     ;;
    'revert')
        revertDirs
        exit 0
    ;;
    'deploy')
        preDeploy
        exit 0
    ;;
    *)
        echo -e ${red}'Invalid First Parameter'${default}
        echo -e ${green}'Valid First Parameters are: install, configure, update, revert and deploy'${default}
        exit 0
    ;;
esac




