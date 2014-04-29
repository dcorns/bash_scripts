#builds mongodb
echo Installing mongodb
gnome-terminal -e 'wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.6.0.tgz'
read -p'Press Enter after download completes, you will know this when second terminal window closes'
function nt(){
mongotar=$(ls *tgz*)
sudo tar xvf "$mongotar"
sudo rm "$mongotar"
}
nt
mongoInstDir=$(ls | grep mongo*)
sudo mv "$mongoInstDir" /opt/mongodb
sudo mkdir /data/db -p
sudo groupadd mongodb
sudo usermod -a -G mongodb $USERNAME
sudo chown $USERNAME:mongodb /data -R
sudo ln -s /opt/mongodb/bin/mongod /usr/local/sbin/mongod
sudo ln -s /opt/mongodb/bin/mongo /usr/local/sbin/mongo
echo mongodb install completed
