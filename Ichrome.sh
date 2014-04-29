#goole-chrome install
echo 'Installing Google Chrome'
sudo touch /etc/yum.repos.d/google-chrome.repo
cd /etc/yum.repos.d
sudo chmod 666 google-chrome.repo
sudo echo '[google-chrome]' >> google-chrome.repo
sudo echo 'name=google-chrome - 64-bit' >> google-chrome.repo
sudo echo 'baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64' >> google-chrome.repo
sudo echo 'enabled=1' >> google-chrome.repo
sudo echo 'gpgcheck=1' >> google-chrome.repo
sudo echo 'gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub' >> google-chrome.repo
sudo chmod 644 google-chrome.repo
sudo yum -y install google-chrome-stable
google-chrome
echo 'Google Chrome install complete'
