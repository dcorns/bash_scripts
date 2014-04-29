#Install and configure git
echo Installing or checking git install
sudo yum -y install git
echo Configuring git globals
echo
echo Enter Your Name:
read gun
git config --global user.name "$gun"
echo
echo Enter Email Address
read gemail
git config --global user.email "$gemail"
git config --global color.ui true
color.status=auto
color.branch=auto
color.interactive=auto
color.diff=auto
git config --global core.editor subl
git config --global merge.tool subl

echo
echo Configuration completed
git config -l
