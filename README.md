bash-scripts
To run them change to the directory where you downloaded them and preceed the script that you want to run with bash (bash Ichrome.sh)

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
lnpm--This, when completed will solve the problem of have node_modules installed in every directory in which you have a node project. It will allow node modules to be read from a centralized directory on the file system and when a particular package does not exist it will download the package to the centralized directory for continued use. No more downloading packages every time you start a new node project and no longer have node packages spread out all over your hard drive.

lnpm.sh install <module_name>
Searches the local directory specified in $nd for the module and if it exist it will do the following as needed:
If no package.json exists, it will run npm.init to interactively create it.
If no dependencies object exists, it will add it to the package.json.
If no reference to the module exists in the dependencies object, it will be added with fixed/latest version, otherwise it will notify that the package is already installed.

lnpm.sh install <module_name> -dev
Performs all the tasks of regular install but also will perform the same steps to add as a dev dependency
If both dependencies and devDependencies have a reference to the module it will exit with package is already installed notification.

lnpm.sh configure
Makes an existing node_modules directory compatible with lnpm by renaming the directories to include versions

lnpm.sh update
Need to implement for updating the local folder modules

lnpm.sh revert
Need to implement for reverting the local directory back to normal package directory names, thus making unusable to lnpm

lnpm.sh deploy
Need to implement for copying modules used by project to the project directory, changing directory names back to just the package name and modifing package.json to have the modified path. So the application can be deployed off the local system.

Overall problems to overcome:
There are different versions of node packages. One may be used in one project and a different version in another project. If the local node_modules folder is simply updated, it will replace the existing version of a module. This will be problematic since projects using older versions will no longer be able to access the version of the module on which it relies.
proposed solution: Add version information of each module to the directory name. Add an 'update' parameter to lnpm that creates the directory structure accordingly when updating from repository. Modify lnpm install to do the same when it adds a missing module from the registry.

############################ Additional Information ##############################
Check back for more bash scripts as I will be adding them as I discover new ways to use them to help make me a more productive developer.

If you have any problems please leave a comment or better yet do a pull request. If you have a script you find useful submit a pull request for that also. I think it would be helpful to have a large repository of scripts to help make us all more productive my not having to type the same thing over and over all the time.

All scripts created to be helpful, however; problems can occur and while I will try to help resolve any issues that may arise, use them at your own risk. See License for details.
