#!/bin/bash

# Check if Puppet package is already installed
[ "$(puppet --version)" = "3.7.4" ] && echo "Puppet '3.7.4' is already installed !" \
   	&& exit 0
# Download puppetlabs-release-wheezy.deb
wget --output-document=/tmp/puppetlabs-release-wheezy.deb https://apt.puppetlabs.com/puppetlabs-release-wheezy.deb

[ -f /tmp/puppetlabs-release-wheezy.deb ] || exit 1
# Install the puppetlabs-release-wheezy.deb which will setup the puppet repos entries in /etc/apt/sources.list.d/puppetlabs.list file.
sudo dpkg -i /tmp/puppetlabs-release-wheezy.deb
sudo apt-get update
# Install puppet 3.7.4 package
sudo apt-get install -y puppet=3.7.4-1puppetlabs1
echo "Puppet $(puppet --version) is now installed."
# Remove the temporary download package
rm /tmp/puppetlabs-release-wheezy.deb
