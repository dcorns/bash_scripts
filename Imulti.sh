#Just installs the packages within installs
#and runs the package updates for gem, npm and yum
function updatePacks(){
sudo yum update -y
gem update
sudo npm update -g
}
updatePacks
sudo yum install postgresql-server -y
sudo yum install redis -y
gem install sass
gem install heroku
wget -qO- https://toolbelt.heroku.com/install.sh | sh
sudo npm install -g node-static
sudo npm -g install jshint
sudo npm install -g grunt-cli
sudo npm install -g bower
sudo npm install -g browserify beefy
sudo npm install -g casperjs
sudo npm install -g phantomjs
updatePacks
