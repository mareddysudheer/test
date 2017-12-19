#!/bin/bash
sudo apt-get update
sudo apt-get install -y firewalld
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=3000/tcp --permanent
sudo firewall-cmd --zone=public --add-port=8140/tcp --permanent
sudo firewall-cmd --zone=public --add-port=8142/tcp --permanent
sudo firewall-cmd --zone=public --add-port=61613/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports
sudo wget https://s3.amazonaws.com/pe-builds/released/2017.3.2/puppet-enterprise-2017.3.2-ubuntu-16.04-amd64.tar.gz
sudo tar -xf puppet-enterprise-2017.3.2-ubuntu-16.04-amd64.tar.gz
#cd puppet-enterprise-2017.3.2-ubuntu-16.04-amd64
sudo sed -i 's/"console_admin_password": ""/  "console_admin_password": "Password@1234"/g' /home/ubuntu/puppet-enterprise-2017.3.2-ubuntu-16.04-amd64/conf.d/pe.conf
sudo sed -i 's/#"puppet_enterprise::console_host": ""/"puppet_enterprise::console_host": "puppet.master.com"/g' /home/ubuntu/puppet-enterprise-2017.3.2-ubuntu-16.04-amd64/conf.d/pe.conf
sudo hostname puppet.master.com
sudo chmod 777 /etc/hosts
sudo echo "127.0.0.1       puppet.master.com">>/etc/hosts
#sed -i 's/localhost/puppet.master.com/g' /etc/hosts
sudo chmod 777 /etc/hostname
sudo echo "" > /etc/hostname
sudo echo "puppet.master.com" > /etc/hostname
sudo /home/ubuntu/puppet-enterprise-2017.3.2-ubuntu-16.04-amd64/puppet-enterprise-installer -c /home/ubuntu/puppet-enterprise-2017.3.2-ubuntu-16.04-amd64/conf.d/pe.conf
#sudo puppet agent -t
sleep 20
echo " Now Puppet enterprise is ready"
sudo puppet module install puppetlabs-ntp
exit 0
