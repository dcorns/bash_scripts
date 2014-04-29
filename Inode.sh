#Node build v0.10.26 with npm
#Uses a directory called drcInstall, if it already exist it may not work
sudo yum install gcc-c++
sudo mkdir drcInstall
cd drcInstall
#version 0.10.26
sudo wget nodejs.org/dist/v0.10.26/node-v0.10.26.tar.gz
nodetar=$(ls *tar*)
sudo tar xvf "$nodetar"
sudo rm "$nodetar"
nodeInstDir=$(ls | grep node*)
cd "$nodeInstDir"
sudo ./configure
sudo make
sudo make install
#set s links
sudo ln -s /usr/local/bin/node /usr/bin/node
#sudo ln -s /usr/local/lib/node /usr/lib/node
sudo ln -s /usr/local//lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm
#sudo ln -s /usr/local/bin/node-waf /usr/bin/node-waf
#Cleanup
cd ..
cd ..
sudo rm drcInstall -R
echo Node install completed
