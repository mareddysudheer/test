#!/bin/bash
apt-get update
apt-get -y install curl

#chef_server_fqdn=$1

# create downloads directory
#if [ ! -d /downloads ]; then
#  mkdir /downloads
#fi
apt-get install -y firewalld
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload
# download the Chef Automate package
#if [ ! -f /downloads/automate_1.6.99-1_amd64.deb ]; then
  echo "Downloading the Chef Automate package..."
 sudo wget -nv -P /root https://packages.chef.io/files/stable/automate/1.6.99/ubuntu/16.04/automate_1.6.99-1_amd64.deb
#fi
wget https://github.com/sudheermareddy/test/raw/master/automate.license -O /tmp/automate.license
# install Chef Automate
if [ ! $(which automate-ctl) ]; then
  echo "Installing Chef Automate..."
  sudo dpkg -i /root/automate_1.6.99-1_amd64.deb

  # run preflight check
  sudo automate-ctl preflight-check

  # run setup
  sudo automate-ctl setup --license /tmp/automate.license --key /tmp/chefuser.pem --server-url https://10.0.0.3/organizations/orguser --fqdn $(hostname) --enterprise default --configure --no-build-node
  sudo automate-ctl reconfigure

  # wait for all services to come online
 # echo "Waiting for services..."
  #until (curl --insecure -D - https://localhost/api/_status) | grep "200 OK"; do sleep 1m && automate-ctl restart; done
 # $while (curl --insecure https://localhost/api/_status) | grep "fail"; do sleep 15s; done

  # create an initial user
 echo "Creating delivery user..."
  sudo automate-ctl create-user default chefuser --password Password@1234 --roles "admin"
fi

echo "Your Chef Automate server is ready!"
