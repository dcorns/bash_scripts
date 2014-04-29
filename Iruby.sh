#Ruby install using rvm
echo Installing ruby with rvm
sudo \curl -sSL https://get.rvm.io | bash
echo 'source ~/.profile' >> ~/.bash_profile
source ~/.bash_profile
rvm install 2.1.1
ruby -v
echo Ruby Installed

