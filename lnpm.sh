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
blue='\e[1;34m'
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
declare -a currentversions
devinstall=$3
declare -a pkgpaths
declare -a pkglist
declare -a verlist
pkgpath=''
pkgver=''
pkgcount=0
#******************************************Functions********************************************************************

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++setupDirs++++++++++++++++++++++++++++++++++++++++++++++
#Configure existing directory that already contains normal node modules to work with lnpm
setupDirs(){
#Rename each directory with a 0-0-0 extention for version identification
    #Proccess directories
    preparedcount=0
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
        echo -e ${green}$dirname 'prepared'${default}
        let preparedcount+=1
    fi
done
    if [ $preparedcount -gt 1 ]; then
        echo -e ${green}$preparedcount directories prepared${default}
    else
        echo -e ${green}$preparedcount directory prepared${default}
    fi
}

#++++++++++++++++++++++++++++++++++++++++++++++++++update+++++++++++++++++++++++++++++++++++++++++++++++++++++++
#add latest packages from npm registry to local directory
update(){
cd $nd
#Run setupDirs in case update is being run on a directory that has not yet configured sub directory names
setupDirs
#Create a temp directory and copy all modules over, striping them their version from directory name
#Run npm update
#Configure the temp directories and copy what does not already exist to the local folder, then remove temp directory and contents
if [ "$pkginstall" == "" ]; then
echo -e ${yellow}'update all chosen: This could take a while. To avoid this include a package to update as the second parameter'${default}
        echo "Enter 'yes' to continue"
        read
        if [ "$REPLY" = 'yes' ]; then
            splitdirnames
            count=0
            pkgchecked=false
            currentpkglist=${pkglist[@]}
            declare -a pkgProccessed
            for pkg in ${currentpkglist[@]}; do
                #pkglist is part of an array set that includes pkgverlist and pkgpaths so pkglist may have duplicate package names. So the following filter is required to avoid multiple upgrades on the same package
                pkgchecked=false
                for ppkg in ${pkgProccessed[@]}; do
                    if [ ${pkg} = ${ppkg} ]; then
                        pkgchecked=true
                    fi
                done
                if [ ${pkgchecked} != true ]; then
                    pkginstall=${pkg}
                    updateLocalPackage ${pkg}
                    pkgProccessed[count]=${pkg}
                    let count+=1
                fi
            done
        else
            echo -e ${red}'user canceled update'${default}
            cd ..
            rm incoming_modules -R
            exit 0
        fi
    else
        echo -e ${yellow}$pkginstall 'module included'${default}
        #verifiy existing package exists, if not offer to install it
        getPackageCount
        if [ ${pkgcount} -lt 1 ]; then
            echo -e ${yellow}'An existing version of' $pkginstall 'was not found, would you like to install it instead? (no to cancel) (yes)'${default}
            read
            if [ "$REPLY" == "no" ]; then
               echo -e ${red}'User cancled update'${default}
               exit 0
            else
                npm install $pkginstall
                setupDirs
                exit 0
            fi
        fi
        updateLocalPackage ${pkginstall}
    fi
    echo -e ${green}'Update Complete'${default}
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++revertDirs+++++++++++++++++++++++++++++++++++++++++++++++++++
#revert the local folder or some other folder to standard package names
revertDirs(){
cd $nd

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
prepDeploy(){
echo 'preDeploy'
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++install++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#*************************************lnpm install code*****************************************************************
install(){
#Check for package locally, else install from repo and setup the directory, else error invalid package
setpackage
#verify or create package.json file
checkpackagejson
#parce package.json and set flags for proccessing
parcepkgjson
#Make package dev and dep lists
makeDepList
makeDevList
#if not already in package.json dependencies object, add it
checkpackageDep
checkpackageDev


if [ "$devinstall" = "-dev" ] || [ "$devinstall" = "--save-dev" ]; then
    if [ $alreadydev = false ]; then
        echo -e ${green}'adding' $pkginstall 'version' $pkgver "to package.json devdependencies"${default}
        addpackageDev
    fi
fi

if [ "$devinstall" = "-save" ] || [ "$devinstall" = "" ]; then
    if [ $alreadydep = false ]; then
    echo -e ${green}'adding' $pkginstall 'version' $pkgver "to package.json dependencies"${default}
    addpackageDep
    fi
fi
echo -e ${green}'Installation complete'${default}
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++check3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#validate the third parameter
check3(){
case $devinstall in
    '-dev') ;;
    '--save-dev') ;;
    '') ;;
    *) echo -e ${red}'The third parameter must be -dev or null'${default}
       exit 0
       ;;
esac
}

splitdirnames(){
    dircount=0
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
    pkgpaths[$dircount]='"'$nd$basedirname'"'
    let dircount=dircount+1
done
}

setpackage()
{
if [ "$pkginstall" != "" ]; then
#see if the package ($pkginstall) exists in the local directory
    #get local package list set currentpaths and currentversions if at least one package is in the list
    getPackageCount
    if [ ${pkgcount} -gt 0 ]; then
        #set package path
        pkgpath=${currentpaths[0]}
        pkgver=${currentversions[0]}
        if [ ${pkgcount} -lt 2 ]; then
        echo -e ${green}$pkgcount $pkginstall 'package found in local directory' $nd${default}
        fi
        #If more than one version then manage (pkgexists advances one more before exiting loop)
        if [ $pkgcount -gt 1 ]; then
        echo -e ${green}$pkgcount $pkginstall 'packages found in local directory' $nd${default}
            echo -e ${blue}'Select Vesion'${default}
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
        setupDirs
        getPackageCount
        if [ $pkgcount -gt 0 ]; then
            echo -e ${green}$pkginstall 'added to local npm storage'${default}
            setpackage
        else
            echo -e ${red}$pkginstall 'does not exist in local directory or in npm repository'${default}
        exit 0
        fi
    fi
else
echo -e ${yellow}'No package specified for installation. Installing from package.json'${default}
convert
fi
}

#check for package.json and if exist, otherwise create it
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
}
#Check for package in dependencies
checkpackageDep(){
if [ $localpackageadded = true ]; then
        echo "New package added, bypass package.json dependencies check"
    else
        p=0;
        while (( ${#deplist[@]} > $p )); do
            if [ $pkginstall = ${deplist[$p]} ]; then
                alreadydep=true
                if [ $pkgver = ${depverlist[$p]} ]; then
                echo -e ${yellow}$pkginstall $pkgver is already in package.json dependencies object${default}
                else
                echo -e ${yellow}'Another version ('${depverlist[p]}') of' ${deplist[p]} 'is already in package.json!'${default}
                exit 0
                fi
            fi
            let p+=1
        done
    fi
}
#Check for package in devdependencies
checkpackageDev(){
if [ $localpackageadded = true ]; then
        echo "New package added, bypass package.json devdependencies check"
    else
        cv=0;
        while (( ${#devlist[@]} > $cv )); do
            if [ $pkginstall == ${devlist[$cv]} ]; then
                if [ $pkgver == ${devverlist[$cv]} ]; then
                alreadydev=true
                echo -e ${yellow}$pkginstall $pkgver is already in package.json devDependencies object${default}
                else
                echo -e ${yellow}'Another version ('${depverlist[p]}') of' ${deplist[p]} 'is already in package.json!'${default}
                exit 0
                fi
            fi
            let cv+=1
        done
    fi
}
addpackageDep(){
#extract package.json lines to array
readarray -t pkgjson < package.json
cd $cwd
#make temp package.json file
touch package.njson
#if dependencies object already exists in package.json just add the package to it
if [ $havedependencies = true ]; then
    while (( ${#pkgjson[@]} > dp )); do
        pkgline=${pkgjson[dp++]}
        echo $pkgline >> package.njson
        dep=$(echo $pkgline | grep -o 'dependencies')
        if [ "$dep" = 'dependencies' ]; then
            echo '"'$pkginstall'"':'"'$pkgver'"'"," >> package.njson
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
                echo '"'$pkginstall'"':'"'$pkgver'"' >> package.njson
                echo "}" >> package.njson
            else
                echo $pkgline >> package.njson
            fi
        let count+=1
    done
fi
writepackagejson
writelink ${pkginstall} ${pkgver}
echo -e ${green}$pkginstall $pkgver 'added to package.json dependencies'${default}
}

addpackageDev(){
#extract package.json lines to array
readarray -t pkgjson < package.json
cd $cwd
#make temp package.json file
touch package.njson
depends='"devDependencies"'
if [ $havedevdependencies = true ]; then
    while (( ${#pkgjson[@]} > ad )); do
        pkgline=${pkgjson[ad++]}
        echo $pkgline >> package.njson
        dep=$(echo $pkgline | grep -o 'devDependencies')
        if [ "$dep" = 'devDependencies' ]; then
            echo '"'$pkginstall'"':'"'$pkgver'"'"," >> package.njson
        fi
    done
else
    size=${#pkgjson[@]}
    let size-=1
    count=1
    while (( ${#pkgjson[@]} > ad )); do
        pkgline=${pkgjson[ad++]}

        dep=$(echo $pkgline | grep -o 'devDependencies')
        #if the result is invalid the if statement will generate error however program still executes as expected
        if [ $size = $count ]; then
            echo $pkgline',' >> package.njson
            depends='"devDependencies"'
            echo $depends': {' >> package.njson
            echo '"'$pkginstall'"':'"'$pkgver'"' >> package.njson
            echo "}" >> package.njson
        else
            echo $pkgline >> package.njson
        fi
        let count+=1
    done
fi
#replace package.json with modified
writepackagejson
writelink ${pkginstall} ${pkgver}
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
#extract package.json lines to array and other stuff that isn't really needed
readarray -t pkgjson < package.json
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
            havedevdependencies=true
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
        echo -e ${green}'building deplist'${default}
        depobjlength=${#depobj[@]}
        dpo=1
        count=0
        while (( depobjlength-1 > dpo )); do
            pkgjsondep=${depobj[dpo]}
            #drop everything after package name
            basepkgdep=${pkgjsondep%%':'*}
            #echo ${basepkgdep}
            #drop everything before package name
            #basepkgdep=${basepkgdep##*'/'}
            #echo ${basepkgdep}
            #drop everything before last version text
            basepkgdepver=${pkgjsondep##*':'}
            #drop the comma if it has one
            basepkgdepver=${basepkgdepver%%','*}
            depverlist[count]=$basepkgdepver
            deplist[count]=$basepkgdep
            let dpo+=1
            let count+=1
        done
    fi
}

#requires devobj, hasdevdependencies
makeDevList(){
    if [ $havedevdependencies = true ]; then
        echo -e ${green}'building devlist'${default}
        devobjlength=${#devobj[@]}
        dvo=1
        count=0
        while (( devobjlength-1 > dvo )); do
            pkgjsondev=${devobj[dvo]}
            #drop everything after package name
            basepkgdev=${pkgjsondev%%':'*}
            #drop everything before package name
            #basepkgdev=${basepkgdev##*'/'}
            #drop everything before last version text
            basepkgdevver=${pkgjsondev##*':'}
            #drop the comma if it has one
            basepkgdevver=${basepkgdevver%%','*}
            devverlist[count]=$basepkgdevver
            devlist[count]=$basepkgdev
            let dvo+=1
            let count+=1
        done
    fi
}

getPackageCount(){
#Checks for versions of pkginstall in the local directory and pkgcount+1 for each version found
#If there is a match, it also sets currentpaths and currentversions arrays to match directories found
    splitdirnames
    pkgidx=0
    pkgcount=0
    for p in ${pkglist[@]}; do
        if [ ${p} = ${pkginstall} ]; then
            echo ${p}
            currentpaths[$pkgcount]=${pkgpaths[$pkgidx]}
            currentversions[$pkgcount]=${verlist[$pkgidx]}
            let pkgcount=${pkgcount}+1
        fi
        let pkgidx=${pkgidx}+1
    done
}

convert(){
    #rm node_modules -R
    #mkdir node_modules
    parcepkgjson
    makeDepList
    makeDevList
    count=0
    for dep in ${deplist[@]}; do
        #check for version in local node storage
        local vrs=$(setVersion ${dep} ${depverlist[${count}]})
        echo ${vrs}
        let count+=1
        #if the version exists create sym link else add and then create sym link
    done
    count=0
    for dev in ${devlist[@]}; do
        #check for version in local node storage
        local devVrs=$(setVersion ${dev} ${devverlist[${count}]})
        echo ${devVrs}
        let count+=1
        #if the version exists create sym link else add and then create sym link
    done
    exit 0
}
#currently obsolete
getLatestLocalVer(){
    local latestLocalVer=0.0.0
    setPackageCount ${1}
    if [ ${pkgcount} -lt 2 ]; then
        latestLocalVer=${currentversions[0]}
    else
        if [ ${pkgcount} -gt 1 ]; then
            cV1=0
            cV2=0
            cV3=0
            cVtest=""
            for cV in ${currentversions[@]}; do
                idx=`expr index ${cV} .`
                cVtest=${cV:${idx}}
                V1=${cV:0:${idx}-1}
                if [ ${V1} -ge ${cV1} ]; then
                    cV1=${V1}
                fi
            done
            for cV in ${currentversions[@]}; do
                idx=`expr index ${cVtest} .`
                V2=${cVtest:0:${idx}-1}
                if [[ ${V1} -eq ${cV1} ]] && [[ ${V2} -ge ${cV2} ]]; then
                    cV2=${V2}
                fi
            done
            for cV in ${currentversions[@]}; do
                cVtest=${cVtest:${idx}}
                if [[ ${V1} -eq ${cV1} ]] && [[ ${V2} -eq ${cV2} ]] && [[ ${cVtest} -gt ${cV3} ]]; then
                    cV3=${cVtest}
                fi
            done
            latestLocalVer=${cV1}.${cV2}.${cV3}
        fi
    fi
    echo ${latestLocalVer}
}

updateLocalPackage(){

    local rver=$(checkForLatestVer ${1})
    if [ ${rver} != 0 ]; then
        cd ${nd}
        npm install ${1}
        setupDirs
        dirsSetup=${preparedcount}
            if [ $dirsSetup -gt 0 ]; then
                echo -e ${green}$1 'version' ${rver} 'added to local package directory.'${default}
            else
                echo -e ${red}$1 'version' ${rver} 'was not added to local package directory.'${default}
            fi
    else
        echo -e ${yellow}'Latest version of' ${1} 'already installed locally'${default}
    fi
}

writeRemoteView(){
    npm view $1 > ${nd}remoteView.tmp
}

getRemoteLatestVer(){
    writeRemoteView $1
    local rvers=$(grep "version:" ${nd}remoteView.tmp)
    #extract from version field to retrieve version number
    local rvers=${rvers#*:} #remove most everything left of the colon
    #get rid of extra space, comma and quotes
    local rverslength=${#rvers}
    rvers=${rvers:2:rverslength-4}
    echo ${rvers}
}

checkForLatestVer(){
#if latest version is local return 0 else return version from remote
local rlv=$(getRemoteLatestVer $1)
setPackageCount ${1}
local result=${rlv}
    for cp in ${currentversions[@]}; do
        if [ ${cp} == ${rlv} ]; then
            result=0
        fi
    done
echo ${result}
}

setPackageCount(){
#Checks for versions of $1 in the local directory and pkgcount+1 for each version found
#If there is a match, it also sets currentpaths and currentversions arrays to match directories found
    splitdirnames
    pkgidx=0
    pkgcount=0
    for p in ${pkglist[@]}; do
        if [ ${p} = $1 ]; then
            currentpaths[$pkgcount]=${pkgpaths[$pkgidx]}
            currentversions[$pkgcount]=${verlist[$pkgidx]}
            let pkgcount=${pkgcount}+1
        fi
        let pkgidx=${pkgidx}+1
    done
}

pickVersion(){
#remove quotes from version($2) and package name ($1)
local result=0
local ln=${#2}
local pkln=${#1}
local apkln=`expr $pkln - 2`
local pkgin=`expr substr $1 2 $apkln`
local verstr=`expr substr $2 1 1`
local strln=${ln}
let strln=${strln}-2
verstr=${2:1:${strln}}
ln=${#verstr}
pkln=${#pkgin}

local notJustNumbers='[~x\*><\^-]'
local anyvers='[~x\*" "]'
local anyMajorMatch='[x\*]'
local anyMinorMatch='[\^~]'
local rgx=''

setPackageCount ${pkgin}

#A length of less than 4 indicates that a full version is not listed
#A length from 0 to 1 indicates x, *, " " or digit test for digit otherwise any versions
#A length of 2 is ~d or ^d or dd
#A length of 3 is d.*, d.x, d.d or ^dd or ~dd
if [ $ln -lt 2 ]; then
    if [[ $verstr =~ $anyvers ]]; then
        echo grab latest version
        local chk=$(checkForLatestVer ${pkgin})
        if [ ${chk} == 0 ]; then
            echo use local latest version
        else
            updateLocalPackage ${pkgin}
        fi
        local iver=$(getLatestLocalVer ${pkgin})
        echo The latest version is ${iver}
        exit 0
    else
        #single digit
        echo get major versions starting with ${verstr}
        rgx='^'${verstr}
        for pc in ${currentversions[@]}; do
            if [[ ${pc} =~ $rgx ]]; then
                echo ${pc}
            fi
        done
        exit 0
    fi
fi
if [ $ln -eq 2 ]; then
    rgx='^[0-9][0-9]$'
    if [[ $verstr =~ $rgx ]]; then
        echo find ${pkgin} version starting with ${verstr}
        rgx='^'${verstr}
        for pc1 in ${currentversions[@]}; do
            if [[ ${pc1} =~ $rgx ]]; then
                echo ${pc1}
            fi
        done
        exit 0
    else
        local m1=`expr substr $verstr 2 1`
        echo find ${pkgin} version starting with ${m1}
        rgx='^'${m1}
        for pc in ${currentversions[@]}; do
            if [[ ${pc} =~ $rgx ]]; then
                echo ${pc}
            fi
        done
        exit 0
    fi
fi
if [ $ln -eq 3 ]; then
    rgx='[\*x]$'
    if [[ $verstr =~ $rgx ]]; then
        echo find 3 length version ${pkgin} starting with `expr substr $verstr 1 1`
    else
        echo find version starting with ${verstr}
    fi
    exit 0
fi
if [ $ln -eq 4 ]; then
    if [[ $verstr =~ $anyMinorMatch ]]; then
        echo find version starting with `expr substr $verstr 2 4`
    else
        echo find version starting with $verstr
    fi
exit 0
fi
if [ $ln -gt 4 ]; then
    if [[ $verstr =~ $notJustNumbers ]]; then
    #determine which non number vaulues are contained in $2
    echo notJustNumbers $verstr
    else
    #its all numbers, just return ver
    echo -e ${green}$verstr${default}
    fi
exit 0
fi

local char1=`expr substr $2 1 2`
local char2=`expr substr $2 3 1`
#echo $char1
case $char1 in
    '"^')
    echo $char1
    ;;
    '"~')
    echo $char1
    ;;
    '">')
    echo $char1
    #test for = as next char
    echo $char2
    ;;
    '"<')
    echo $char1
    #test for = as next char
    echo $char2
    ;;
    '"*')
    echo $char1
    ;;
    *)
    ;;
esac
#echo `expr substr $2 2 1`
#echo $2
}
parceVersion(){
local result=0
local ln=${#2}
local pkln=${#1}
local apkln=`expr $pkln - 2`
local pkgin=`expr substr $1 2 $apkln`
local verstr=`expr substr $2 1 1`
local strln=${ln}
let strln=${strln}-2
verstr=${2:1:${strln}}
ln=${#verstr}
pkln=${#pkgin}

#load currentversion array with versions for pkgin
setPackageCount ${pkgin}
#Prerelease x.x.x-[0-9A-Za-z-].[0-9A-Za-z-].[0-9A-Za-z-] ect. Prerelease always less than release (1.2.4 > 1.2.4-alfa)
rgx='^[~\^]{0,1}?[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*-'
if [[ $verstr =~ $rgx ]]; then
    echo preRelease of ${pkgin}
    exit 0
fi
#Exact version
local rgx='^[~]{0,1}?[0-9][0-9*\.[0-9][0-9]*\.[0-9][0-9]*$'
if [[ $verstr =~ $rgx ]]; then
    echo Exact version ${verstr} ${pkgin}
    exit 0
fi
#Compatible version x.x.x
local rgx='^\^[0-9][0-9*\.[0-9][0-9]*\.[0-9][0-9]*$'
if [[ $verstr =~ $rgx ]]; then
    echo ${verstr}
    exit 0
fi
#Starts with
local rgx='~[0-9][0-9*\.[0-9][0-9]*\.[0-9][0-9]*$'
if [[ $verstr =~ $rgx ]]; then
    echo ${verstr}
    exit 0
fi
#Compatible 0.x.x version unstable exact version required
local rgx='^\^0\.[0-9][0-9]*\.[0-9][0-9]*$'
if [[ $verstr =~ $rgx ]]; then
    echo `expr substr $verstr 2 $((${#verstr}-1))`
    exit 0
fi
#Any version
rgx='^[x\* ]$'
if [[ $verstr =~ $rgx ]]; then
    echo grab latest version
    local chk=$(checkForLatestVer ${pkgin})
    if [ ${chk} == 0 ]; then
        echo use local latest version
    else
        updateLocalPackage ${pkgin}
    fi
        local iver=$(getLatestLocalVer ${pkgin})
        echo The latest version is ${iver}
        exit 0
fi
#Major version
rgx='^[~\^]{0,1}?[0-9][0-9]*$|^[0-9][0-9]*\.[\*x]{0,1}$'
if [[ $verstr =~ $rgx ]]; then
    echo Major version requested for ${pkgin} ${verstr}
    #local edge=`expr substr $verstr 1 1`
    #if [ $edge = ^ ]; then
        #echo the ^
        #exit 0
    #fi
    #edge=`expr substr $verstr 1 1`
    #if [ $edge = ~ ]; then
        #echo the ~
        #exit 0
    #fi
    #edge=`expr substr $verstr $((${#verstr}-1)) 1`
    #if [ $edge = x ]; then
        #echo the x
        #exit 0
    #fi
fi
#Minor version
rgx='^[~\^]{0,1}?[0-9][0-9]*\.[0-9][0-9]*$|^[0-9][0-9]*\.[0-9][0-9]*\.[\*x]{0,1}$'
if [[ $verstr =~ $rgx ]]; then
    echo Minor version requested for ${pkgin}
fi
#Greater than specific version
rgx='^>[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$'
if [[ $verstr =~ $rgx ]]; then
    echo Greater than version $verstr requested for ${pkgin}
fi
#Less than specific version
rgx='^<[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$'
if [[ $verstr =~ $rgx ]]; then
    echo Less than version $verstr requested for ${pkgin}
fi
#Greater than or equal to specific version
rgx='^>=[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$'
if [[ $verstr =~ $rgx ]]; then
    echo Greater than or equal to version $verstr requested for ${pkgin}
fi
#Less than or equal to a specific version
rgx='^<=[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$'
if [[ $verstr =~ $rgx ]]; then
    echo Less than or equal to version $verstr requested for ${pkgin}
fi

#Build meta-data included x.x.x.x...+ ignore everything after the plus for presidence

#Range [- ||] x.x.x - x.x.x, x.x.x && x.x.x, x.x.x or x.x.x

#~ Any version starting with x

#^ Any version compatible with x.x the difference between ~ is that 1.5 will statisfy ^1.1 however ^1 and ~1 are equal since 1 cant become 2 and still satisfy ^
}

setVersion(){
local result=0
local ln=${#2}
local pkln=${#1}
local apkln=`expr $pkln - 2`
local pkgin=`expr substr $1 2 $apkln`
local verstr=`expr substr $2 1 1`
local strln=${ln}
local rgx=''
local verin=0.0.0
let strln=${strln}-2
verstr=${2:1:${strln}}
ln=${#verstr}
pkln=${#pkgin}

#load currentversion array with versions for pkgin
setPackageCount ${pkgin}

#Any version
rgx='^[x\* ]$'
if [[ $verstr =~ $rgx ]]; then
    echo grab latest version
    local chk=$(checkForLatestVer ${pkgin})
    if [ ${chk} == 0 ]; then
        echo use local latest version
    else
        updateLocalPackage ${pkgin}
    fi
        local iver=$(getLatestLocalVer ${pkgin})
        echo The latest version is ${iver}
        exit 0
fi
#Exact version
local rgx='^[~]{0,1}?[0-9][0-9*\.[0-9][0-9]*\.[0-9][0-9]*$'
if [[ $verstr =~ $rgx ]]; then
    echo Exact version ${verstr} ${pkgin}
    exit 0
fi
#Compatible ^
rgx='^\^'
if [[ ${verstr} =~ $rgx ]]; then
    verin=`expr substr ${verstr} 2 $((${#verstr}-1))`
    echo Compatible to ${pkgin} version ${verin}
    exit 0
fi
#Reasonably close ~
rgx='^~'
if [[ ${verstr} =~ $rgx ]]; then
    verin=`expr substr ${verstr} 2 $((${#verstr}-1))`
    echo Reasonably close to ${pkgin} version ${verin}
    exit 0
fi
#Greater than equal
rgx='^>='
if [[ ${verstr} =~ $rgx ]]; then
    verin=`expr substr ${verstr} 3 $((${#verstr}-2))`
    echo Greater than equal to ${pkgin} version ${verin}
    exit 0
fi

#Less than equal
rgx='^<='
if [[ ${verstr} =~ $rgx ]]; then
    verin=`expr substr ${verstr} 3 $((${#verstr}-2))`
    echo Less than equal to ${pkgin} version ${verin}
    exit 0
fi
#Less than
rgx='^<'
if [[ ${verstr} =~ $rgx ]]; then
    verin=`expr substr ${verstr} 2 $((${#verstr}-1))`
    echo Less than ${pkgin} version ${verin}
    exit 0
fi

#Greater than
rgx='^>'
if [[ ${verstr} =~ $rgx ]]; then
    verin=`expr substr ${verstr} 2 $((${#verstr}-1))`
    echo Greater than ${pkgin} version ${verin}
    exit 0
fi

#Any sub release
rgx='[x\*]$'
if [[ ${verstr} =~ $rgx ]]; then
    verin=`expr substr ${verstr} 1 $((${#verstr}-2))`
    echo Sub Release ${pkgin} version ${verin}
    exit 0
fi
}

writelink(){
# $1 package name $2 package version
mkdir ${cwd}/node_modules || continue
ln -s ${nd}/$1"--"$2 ${cwd}/node_modules/$1
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
        revertDirs
        exit 0
    ;;
    'prepdeploy')
        prepDeploy
        exit 0
    ;;
    'convert')
        convert
        exit 0
    ;;
    *)
        echo -e ${red}'Invalid First Parameter'${default}
        echo -e ${green}'Valid First Parameters are: install, configure, convert, update, revert and prepdeploy'${default}
        exit 0
    ;;
esac