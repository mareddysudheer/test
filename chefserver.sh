#!/bin/bash
sudo apt-get update
sudo apt-get -y install curl

#chef_automate_fqdn=$1
 
# create staging directories
if [ ! -d /downloads ]; then
sudo mkdir /downloads
fi
 
# download the Chef server package
if [ ! -f /downloads/chef-server-core_12.16.2_amd64.deb ]; then
echo "Downloading the Chef server package..."
sudo wget -nv -P /downloads https://packages.chef.io/files/stable/chef-server/12.16.2/ubuntu/16.04/chef-server-core_12.16.2-1_amd64.deb
fi
 
# install Chef server
if [ ! $(which chef-server-ctl) ]; then
echo "Installing Chef server..."
sudo dpkg -i /downloads/chef-server-core_12.16.2-1_amd64.deb
sudo chef-server-ctl reconfigure
 
echo "Waiting for services..."
until (curl -D - http://localhost:8000/_status) | grep "200 OK"; do sleep 15s; done
while (curl http://localhost:8000/_status) | grep "fail"; do sleep 15s; done
fi
 
# create user and organization
if [ ! $(sudo chef-server-ctl user-list | grep delivery) ]; then
echo "Creating delivery user and irguser organization..."
sudo chef-server-ctl user-create delivery Chef Admin admin@4thcoffee.com Passsword@1234 --filename /etc/opscode/chefuser.pem
sudo chef-server-ctl org-create orguser "Fourth Coffee, Inc." --association_user delivery --filename /etc/opscode/orguser-validator.pem
fi
 
# configure data collection
sudo chef-server-ctl set-secret data_collector token '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506'
sudo chef-server-ctl restart nginx

 sudo chef-server-ctl reconfigure
 sudo chmod 777 /etc/opscode/chef-server.rb
 sudo echo "data_collector['root_url'] = 'https://10.0.0.4/data-collector/v0/'" >> /etc/opscode/chef-server.rb
 sudo hostname 10.0.0.3
# configure push jobs
if [ ! $(which opscode-push-jobs-server-ctl) ]; then
echo "Installing push jobs server..."
sudo wget -nv -P /downloads https://packages.chef.io/files/stable/opscode-push-jobs-server/2.2.2/ubuntu/16.04/opscode-push-jobs-server_2.2.2-1_amd64.deb
sudo chef-server-ctl install opscode-push-jobs-server --path /downloads/opscode-push-jobs-server_2.2.2-1_amd64.deb
sudo opscode-push-jobs-server-ctl reconfigure

sudo chef-server-ctl reconfigure
fi
sudo apt-get install -y firewalld
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --reload
sudo wget https://raw.githubusercontent.com/sudheermareddy/test/master/ssh_private_key.pem
sudo chmod 000 ssh_private_key.pem
sudo scp -o StrictHostKeyChecking=no  -i ssh_private_key.pem /etc/opscode/chefuser.pem  ubuntu@10.0.0.4:/tmp
echo "Your Chef server is ready!"
