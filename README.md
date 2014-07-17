bash-scripts
run by using ./<script name><parameters>

alternativly change the permissions on the script: (chmod u+x extraGitInit.sh) and you will be able to run them by typing in the name alone.

You could also create a directory to keep them in and add it to your path variable (export PATH="$PATH:~/scripts") so you can run them from any where.

Furthermore, create a symbolic link to save yourself some typing (ln -s /data/scripts/extraGitInit.sh ginit)

########### Fedora Development Setup Scripts ###########
These scripts are useful primarily for setting up a developement system after a fresh install of a Fedora20 distro of linux; however some of them may be useful for other distros as well.

Before using these scripts, you will want to run 'sudo yum update -y' to get all the existing packages up to date.

If you are using these scripts to install an entire development environment on fedora, make sure to do them in the order listed here. Some scripts will require a restart before the settings will take effect.

Ichrome.sh--Installs google chrome and adds it to the application menu.

Iruby.sh--Installs the latest ruby and the rvm version manager for ruby

Isublime.sh--Installs sublimeText3 along with a number of packages for making it more useful for development. Take a look at line 45 if you want to add or subtract the packages that will be installed.

Inode.sh--Installs and configures the latest version of nodejs and npm

Imongod.sh--Installs and configures a single server instance of mongodb. note: you end up with a default db of local as opposed to the usual test

Igit--installs git and runs some interactive prompts for setting some of the global configuration

########### Additional Scripts ###########

These scripts are intended to be useful on any distro and in most cases on both linux and mac.

extraGitinit.sh--This will initialize a local git, create an MIT License file and a blank README.md, create a matching repository on github and a remote to push and pull with. It also adds a testing branch to the local git. You must first alter lines 37 and 39 to by replacing <YourGitHubSite> with your git hub site and <YourGitHubUserName> with your git hub user name. After doing that I would suggest setting up a symbolic link to it as it will prove quite useful if you are doing a lot of projects.
##################### lnpm.sh Manage and distribute node package functionality in local file structure ##############################################
lnpm--This script solves the problem of having node_modules installed in every directory in which you have a node project. It allows node modules to be read from a centralized directory on the file system and when a particular package does not exist it will download the package to the centralized directory for continued use. No more downloading packages every time you start a new node project and no longer do node packages have to be spread out all over your hard drive. Every version of a package in use conveniently stored in one place.

BEFORE USING lnpm.sh YOU MUST CHANGE THE nd VARIABLE LINE 6 OF THE SCRIPT TO POINT TO THE FULL PATH OF THE DIRECTORY YOU WILL USE TO STORE THE NODE PACKAGES

After that is done, the easiest way to get started is to copy and existing node_modules directory from one of your existing projects to where you want your centralized location. Then run lnpm configure. This will change all the directory names to <packagename>---<version>. This makes the packages usable with lnpm and your ready to go. You could simply create an empty directory and assign it to nd, but this way will save you some downloading which is one of the main reasons to use this script. You can easily add other packages to the nd directory at anytime and run lnpm configure again to setup the new directories.

lnpm.sh install <package name>
Searches the local directory for the package and if it exist it will do the following as needed:
If no package.json exists, it will run npm.init to interactively create it.
If no dependencies object exists, it will add it to the package.json.
If no reference to the package exists in the dependencies object, it will be added.
If the package does not exist in the local directory, it will be download and assimilated into the local directory and the previous steps will then be carried out.
Note that if there is more that one version of a package in the local directory, you will be prompted for the one to install.

lnpm.sh install <module_name> -dev
Performs all the tasks of regular install but also will perform the same steps to add as a dev dependency
If both dependencies and devDependencies have a reference to the module it will exit with a package is already installed notification.

lnpm.sh configure
Makes an existing node_modules directory compatible with lnpm by renaming the directories to include versions

lnpm.sh update
Need to implement for updating the local folder modules

lnpm.sh revert
Reverts the lmpm modules directory directories to standard node names. Since lnpm allows the centralized storage of multiple package versions by adding the version to the directory name, directories that are part of a multi-version package will remain unaltered. You will need to choose a version and rename the directory manually

lnpm.sh deploy
Need to implement for copying modules used by project to the project directory, changing directory names back to just the package name and modifying package.json to have the modified path. So the application can be deployed off the local system.


############################ Additional Information ##############################
Check back for more bash scripts as I will be adding them as I discover new ways to use them to help make me a more productive developer.

If you have any problems please leave a comment or better yet do a pull request. If you have a script you find useful submit a pull request for that also. I think it would be helpful to have a large repository of scripts to help make us all more productive my not having to type the same thing over and over all the time.

All scripts created to be helpful, however; problems can occur and while I will try to help resolve any issues that may arise, use them at your own risk. See License for details.
