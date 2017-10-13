#!/bin/bash
apt-get update
apt-get -y install curl

#chef_server_fqdn=$1

# create downloads directory
if [ ! -d /downloads ]; then
  mkdir /downloads
fi

# download the Chef Automate package
if [ ! -f /downloads/automate_1.6.99-1_amd64.deb ]; then
  echo "Downloading the Chef Automate package..."
  wget -nv -P /downloads https://packages.chef.io/files/stable/automate/1.6.99/ubuntu/16.04/automate_1.6.99-1_amd64.deb
fi
wget https://github.com/sudheermareddy/test/raw/master/automate.license -O /tmp/automate.license
# install Chef Automate
if [ ! $(which automate-ctl) ]; then
  echo "Installing Chef Automate..."
  dpkg -i /downloads/automate_1.6.99-1_amd64.deb

  # run preflight check
  automate-ctl preflight-check

  # run setup
  automate-ctl setup --license /tmp/automate.license --key /tmp/chefuser.pem --server-url https://10.0.0.3/organizations/orguser --fqdn $(hostname) --enterprise default --configure --no-build-node
  automate-ctl reconfigure

  # wait for all services to come online
  echo "Waiting for services..."
  until (curl --insecure -D - https://localhost/api/_status) | grep "200 OK"; do sleep 1m && automate-ctl restart; done
  while (curl --insecure https://localhost/api/_status) | grep "fail"; do sleep 15s; done

  # create an initial user
 echo "Creating delivery user..."
  automate-ctl create-user default chefuser --password Password@1234 --roles "admin"
fi

echo "Your Chef Automate server is ready!"
