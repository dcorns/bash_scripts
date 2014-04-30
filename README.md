bash-scripts
To run them change to the directory where you downloaded them and preceed the script that you want to run with bash (bash Ichrome.sh)

alternativly change the permissions on the script: (chmod u+x extraGitInit.sh) and you will be able to run them by typing in the name alone.

You could also create a directory to keep them in and add it to your path variable (export PATH="$PATH:~/scripts") so you can run them from any where.

Furthermore, create a symbolic link to save yourself some typing (ln -s /data/scripts/extraGitInit.sh ginit)


These scripts are useful primarily for setting up a developement system after a fresh install of a Fedora20 distro of linux; however some of them may be useful for other distros as well.

Before using these scripts, you will definetly want to run 'sudo yum update -y' to get all the existing packages up to date.

If you are using these scripts to install an entire developement environment on fedora, make sure to do them in the order listed here. Some scripts will require a restart before the settings will take effect.

Ichrome.sh--Installs google chrome and adds it to the application menu.

Iruby.sh--Installs the latest ruby and the rvm version manager for ruby

Isublime.sh--Installs sublimeText3 alonge with a number of packages for making it more useful for developement. Take a look at line 45 if you want to add or subtract the packages that will be installed.

Inode.sh--Installs and configures the latest version of nodejs and npm

Imongod.sh--Installs and configures a single server instance of mongodb. note: you end up with a default db of local as opposed to the usual test

Igit--installs git and runs some interactive prompts for setting some of the global configuration

########### Additional Scripts ###########

These scripts are intended to be useful on any distro and in some case on both linux and mac.

extraGitinit.sh--This will initialize a local git, create an MIT License file and a blank README.md, create a matching repository on github and a remote to push and pull with. It also adds a testing branch to the local git. You must first alter lines 37 and 39 to by replacing <YourGitHubSite> with your git hub site and <YourGitHubUserName> with your git hub user name. After doing that I would suggest setting up a symbolic link to it as it will prove quite useful if you are doing alot of projects.


############################ Additional Information ##############################
Check back for more bash scripts as I will be adding them as I discover new ways to use them to help make me a more productive developer.

If you have any problems please leave a comment or better yet do a pull request. If you have a script you find useful submit a pull request for that also. I think it would be helpful to have a large repository of scripts to help make us all more productive my not having to type the same thing over and over all the time.

All scripts created to be helpful, however; problems can occur and while I will try to help resolve any issues that may arise, use them at your own risk. See License for details.
