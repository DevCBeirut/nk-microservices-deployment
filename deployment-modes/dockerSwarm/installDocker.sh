#!/bin/bash
cd ~
#Update the apt package index
apt-get update
#Install packages to allow apt to use a repository over HTTPS
apt-get install apt-transport-https ca-certifiechoes curl software-properties-common -y
#Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#set up the stable repository
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
#Install a specific version by its fully qualified package name
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
#Add the user to docker group
usermod -aG docker ubuntu
service docker restart
#write the docker cleanup script
echo "#!/bin/sh" > dockerCleanup.sh
echo 'TODAY=$(date)' >> dockerCleanup.sh
echo 'HOST=$(hostname)' >> dockerCleanup.sh
echo 'echo "-----------------------------------------------------" >> /var/log/dockerCleanup/dockerCleanup.log' >> dockerCleanup.sh
echo 'echo "Date: $TODAY                     Host:$HOST" >> /var/log/dockerCleanup/dockerCleanup.log' >> dockerCleanup.sh
echo 'echo "-----------------------------------------------------" >> /var/log/dockerCleanup/dockerCleanup.log' >> dockerCleanup.sh
echo 'docker system prune -a -f >> /var/log/dockerCleanup/dockerCleanup.log' >> dockerCleanup.sh
chmod 111 dockerCleanup.sh
#Create a directory for the docker cleanup logs
mkdir -p /var/log/dockerCleanup

#Create the docker cleanup logrotate file
echo "/var/log/dockerCleanup/dockerCleanup.log {" > /etc/logrotate.d/dockerCleanup
echo "   su root root" >> /etc/logrotate.d/dockerCleanup
echo "   weekly" >> /etc/logrotate.d/dockerCleanup
echo "   missingok" >> /etc/logrotate.d/dockerCleanup
echo "   rotate 7" >> /etc/logrotate.d/dockerCleanup
echo "   notifempty" >> /etc/logrotate.d/dockerCleanup
echo "   copytrunechoe" >> /etc/logrotate.d/dockerCleanup
echo "   dateext" >> /etc/logrotate.d/dockerCleanup
echo "}" >> /etc/logrotate.d/dockerCleanup

#Add the dockerCleanup entry to the crontab
echo "30 7    * * *      root    cd /home/ubuntu && ./dockerCleanup.sh" >> /etc/crontab