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
localpackageadded=false
alreadydep=false
alreadydev=false
declare -a depobj
declare -a devobj
declare -a pkgjson
declare -a deplist
declare -a depverlist
declare -a devlist
declare -a devverlist
cwd=$(pwd)
#Add parameters to function scopes
pkginstall=$2
declare -a currentpaths
declare -a curentversions
devinstall=$3
declare -a pkgpaths
declare -a pkglist
declare -a verlist
pkgpath=''
pkgver=''
#******************************************Functions********************************************************************

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
    vers=${ver#*:} #remove most everything left of the colon
    #get rid of extra space, comma and quotes
    verslength=${#vers}
    vers=${vers:2:verslength-4}
    newdir=$pknam--$vers
    cd ..
    #if the directory does not have a version number with name add it here otherwise leave alone
    if [ "$newdir" != "$dirname" ]; then
        mv $dirname "$newdir"
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
echo -e ${yellow}'directory name (normally just package name), this proccess will not alter'${default}
echo -e ${yellow}'directory names that are part multi packages you will need to rename the version desired manually'${default}
echo -e ${yellow}'Enter yes to continue'${default}
read
if [ "$REPLY" != 'yes' ]; then
    exit 0
fi
dircount=0
dupscount=0
for path in $nd*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    dirname="$(basename "${path}")"
    cd "$dirname"
    #remove everything in directory name including double dash to end to get package name
    basedir=${dirname%%'--'*}
    #remove everything in directory name including double dash to front to get version
    vers=${dirname##*'--'}
    #check for multi-version packages and add version back to the directory name of duplicates

    for i in ${adir[@]};do
    if [ ${i} = $basedir ]; then
        duprecorded=false
        for ii in ${dups[@]};do
            if [ ${ii} = ${i} ]; then
                duprecorded=true
            fi
        done
        if [ $duprecorded != true ]; then
                #dupdir=$basedir
                #basedir=$basedir'--'$vers
                #echo $basedir
                dups[dupscount]=$basedir
                let dupscount=dupscount+1
        fi
    fi
    done
    adir[$dircount]=$basedir
    edir[$dircount]=$dirname
    cd ..
    let dircount=dircount+1
done

dircount=0
for j in ${adir[@]};do
    isdup=false
     for k in ${dups[@]};do
        if [ ${j} = ${k} ]; then
            isdup=true
        fi
    done
    if [ $isdup != true ]; then
    mv ${edir[$dircount]} ${j}
    fi
    let dircount=dircount+1
done

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
#Check for package locally, else install from repo, else error invalid package
setpackage
#verify or create package.json file if exists check for existance of package in file
checkpackagejson
#parce package.json and set flags for proccessing
parcepkgjson
#Make package dev and dep lists
makeDepList
makeDevList
exit 0
#if not already in package.json dependencies object, add it
checkpackageDep

if [ $alreadydep = false ]; then
    echo -e ${green}'adding' $pkginstall 'version' $pkgver "to package.json dependencies"${default}
    addpackageDep
fi
#if parameter 3 -dev add as a devdependency
if [ "$devinstall" = "-dev" ]; then
    checkpackageDev
    if [ $alreadydev = false ]; then
        echo -e ${green}'adding' $pkginstall 'version' $pkgver "to package.json devdependencies"${default}
        addpackageDev
    fi
fi
echo -e ${green}'Installation complete'${default}
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++check3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#validate the third parameter
check3(){
case $devinstall in
    '-dev') ;;
    '') ;;
    *) echo -e ${red}'The third parameter must be -dev or null'${default}
       exit 0
       ;;
esac
}

splitdirnames(){
    for path in $nd*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    basedirname="$(basename "${path}")"
    #remove everything in directory name including double dash to end to get package name
    basedir=${basedirname%%'--'*}
    #remove everything in directory name including double dash to front to get version
    vers=${basedirname##*'--'}
    #add values to arrays
    pkglist[$dircount]=$basedir
    verlist[$dircount]=$vers
    pkgpaths[$dircount]=$nd$basedirname
    let dircount=dircount+1
done
}

setpackage()
{
if [ $pkginstall != '' ]; then
#see if the package ($pkginstall) exists in the local directory
    #get local package list set currentpaths and currentversions if at least one package is in the list
    splitdirnames
    pkgexists=0
    pkgidx=0
    for p in ${pkglist[@]}; do
        if [ ${p} = $pkginstall ]; then
            currentpaths[$pkgexists]=${pkgpaths[$pkgidx]}
            currentversions[$pkgexists]=${verlist[$pkgidx]}
            let pkgexists=${pkgexists}+1
        fi
        let pkgidx=${pkgidx}+1
    done
    if [ ${pkgexists} -gt 0 ]; then
        #set package path
        pkgpath=${currentpaths[0]}
        pkgver=${currentversions[0]}
        echo -e ${green}$pkgexists 'package/s found in local directory' $nd${default}
        #If more than one version then manage (pkgexists advances one more before exiting loop)

        if [ $pkgexists -gt 1 ]; then
            echo 'Select Vesion'
            options=${currentversions[@]}
            select s in $options; do
            count=0
            for cv in ${currentversions[@]}; do
                if [ $cv = $s ]; then
                    pkgpath=${currentpaths[count]}
                    pkgver=${currentversions[count]}
                fi
                let count=${count}+1
            done
            break
            done
        fi
#not in local directory, download it if it exists in npm registry
    else
        echo -e ${yellow}$pkginstall 'not found in local directory'
        echo -e ${green}'Installing module from npm external repository'${default}
        cd $nd
        npm install $pkginstall
        m=$(find $pkginstall)
        if [ '$m' = ${pkginstall} ]; then
            echo -e ${green}$pkginstall 'added to local npm storage'${default}
            localpackageadded=true
        else
            echo -e ${red}$pkginstall 'does not exist in local directory or in npm repository'${default}
        exit 0
        fi
    fi
else
echo -e ${red}'Package' $pkginstall 'not found locally or externally'${default}
exit 0
fi
}

#check for package.json and if exist, otherwise create it, and read into pkgjson array
checkpackagejson()
{
#check for package.json and npm init if it does not exist
cd $cwd
pkg=$(find package.json)
if [ "$pkg" = 'package.json' ]; then
    echo -e ${green}"Found package.json"${default}
else
npm init
fi
#extract package.json lines to array
readarray -t pkgjson < package.json
}
#Check for package in dependencies
checkpackageDep(){
if [ localpackageadded = true ]; then
        echo "New package added, bypass package.json dependencies check"
    else
        while (( ${#deplist[@]} > p )); do
            if [ $pkginstall = deplist[p++] ]; then
                alreadydep=true
                echo -e ${yellow}$installpackage is already in package.json dependencies object${default}
                break
            fi
        done
        #installpackage=$(grep $pkginstall package.json) #simple grep all that is required cause in package.json it will always be in as a dependencies if not also as a devdependencies
        #if [ ${#installpackage} -gt 0 ]; then
        #check for multi versions and if exists then display choices noting that a version already exists in package.json
        #but for now simply note a version is installed and skip adding it
           # alreadydep=true
            #echo -e ${yellow}$installpackage is already in package.json dependencies object${default}
        #fi
    fi
}
#Check for package in devdependencies
checkpackageDev(){
if [ localpackageadded = true ]; then
        echo "New package added, bypass package.json devdependencies check"
    else
        installpackage=$(grep $pkginstall package.json)
        echo $installpackage
        if [ ${#installpackage} -gt 0 ]; then
        #check for multi versions and if exists then display choices noting that a version already exists in package.json
        #but for now simply note a version is installed and skip adding it
            alreadydev=true
            echo -e ${yellow}$installpackage is already in package.json devdependencies object${default}
        fi
    fi
}
addpackageDep(){
cd $cwd
#make temp package.json file
touch package.njson
#if dependencies object already exists in package.json just add the package to it
if [ $havedependencies = true ]; then
    while (( ${#pkgjson[@]} > i )); do
        pkgline=${pkgjson[i++]}
        echo $pkgline >> package.njson
        dep=$(echo $pkgline | grep -o 'dependencies')
        if [ "$dep" = 'dependencies' ]; then
            echo $pkgpath":" $pkgver"," >> package.njson
        fi
    done
else
#create dependencies object and add the package to it
    size=${#pkgjson[@]}
    let size-=1
    count=1
    while (( ${#pkgjson[@]} > dp )); do
        pkgline=${pkgjson[dp++]}
            if [ $size = $count ]; then
                echo $pkgline',' >> package.njson #add comma to last object
                depends='"dependencies"'
                echo $depends': {' >> package.njson
                echo $pkgpath ":" $pkgver >> package.njson
                echo "}" >> package.njson
            else
                echo $pkgline >> package.njson
            fi
        let count+=1
    done
fi
writepackagejson
echo -e ${green}$pkginstall $pkgver 'added to package.json dependencies'${default}
}

addpackageDev(){
cd $cwd
#make temp package.json file
touch package.njson
depends='"devDependencies"'
if [ $havedevdependencies = true ]; then
    while (( ${#pkgjson[@]} > i )); do
        pkgline=${pkgjson[i++]}
        echo $pkgline >> package.njson
        dep=$(echo $pkgline | grep -o 'devDependencies')
        #if the result is invalid the if statement will generate error however program still executes as expected
        if [ "$dep" = 'devDependencies' ]; then
            echo $pkgpath":" $pkgver"," >> package.njson
        fi
    done
else
    size=${#pkgjson[@]}
    let size-=1
    count=1
    while (( ${#pkgjson[@]} > i )); do
        pkgline=${pkgjson[i++]}

        dep=$(echo $pkgline | grep -o 'devDependencies')
        #if the result is invalid the if statement will generate error however program still executes as expected
        if [ $size = $count ]; then
            echo $pkgline',' >> package.njson
            depends='"devDependencies"'
            echo $depends': {' >> package.njson
            echo $pkgpath ":" $pkgver >> package.njson
            echo "}" >> package.njson
        else
            echo $pkgline >> package.njson
        fi
        let count+=1
    done
fi
#replace package.json with modified
writepackagejson
echo -e ${green}$pkginstall $pkgver 'added to package.json devdependencies'${default}
}
writepackagejson(){
rm package.json
mv package.njson package.json
}
#sets havedependencies and havedevdependencies if exists, stores existing dependencies and devDependencies objects to
#depobj and devobj respectively
#requires pkgjson
parcepkgjson(){
count=1
depstart=false
devstart=false
depcount=0
devcount=0
echo -e ${green}'Reading package.json'${default}
    while (( ${#pkgjson[@]} > i )); do
        pkgline=${pkgjson[i++]}
        testforDep=$(echo $pkgline | grep -o 'dependencies')
        if [ "$testforDep" == "dependencies" ]; then
            havedependencies=true
            depstart=true
        fi
        if [ $depstart = true ]; then
            depend=$(echo $pkgline | grep -0 '}')
            if [ "$depend" != "}," ] && [ "$depend" != "}" ]; then
                depobj[$depcount]=$pkgline
                let depcount+=1
            else
                depobj[$depcount]=$pkgline
                let depcount+=1
                depstart=false
            fi
        fi
        testforDevDep=$(echo $pkgline | grep -o 'devDependencies')
        if [ "$testforDevDep" == "devDependencies" ]; then
            hasdevdependencies=true
            devstart=true
        fi
        if [ $devstart = true ]; then
            devend=$(echo $pkgline | grep -0 '}')
            if [ "$devend" != "}" ] && [ "$devend" != "}," ]; then
                devobj[$devcount]=$pkgline
                let devcount+=1
            else
                devobj[$devcount]=$pkgline
                let devcount+=1
                devstart=false
            fi
        fi
        let count+=1
    done
}

#requires depobj, hasdependencies
makeDepList(){
    if [ $havedependencies = true ]; then
        echo 'build deplist' , $pkgpath , $pkginstall , $pkgver
        depobjlength=${#depobj[@]}
        dpo=1
        count=0
        while (( depobjlength-1 > dpo )); do
            pkgjsondep=${depobj[dpo]}
            #drop everything after package name
            basepkgdep=${pkgjsondep%%'--'*}
            #drop everything before package name
            basepkgdep=${basepkgdep##*'/'}
            echo $basepkgdep , ${#basepkgdep}
            deplist[count]=$basepkgdep
            echo ${deplist[count]}
            let dpo+=1
        done
    fi
}

#requires devobj, hasdevdependencies
makeDevList(){
    if [ $havedevdependencies = true ]; then
        echo 'build devlist'
        devobjlength=${#devobj[@]}
        dvo=1
        while (( devobjlength-1 > dvo )); do
            echo ${devobj[dpo]}
            let dvo+=1
        done
    fi
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




