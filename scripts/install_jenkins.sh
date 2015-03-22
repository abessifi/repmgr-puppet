#!/bin/bash

# Check if Jenkins package is already installed
dpkg-query -W -f='Jenkins: ${Status}\nVersion: ${Version}\n' jenkins 2>/dev/null && service jenkins status && exit 0
# Install Jenkins otherwise
# First add the key to the system
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
# Add the following entry to /etc/apt/sources.list.d/jenkins-ci.list
echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins-ci.list
# Update the local package index and install jenkins
sudo apt-get update
sudo apt-get install -y jenkins
[ $? -ne 0 ] && echo "Unexpected error occured during installation!" && exit 1
echo "Jenkins $(dpkg-query -W -f='${Version}' jenkins) is now installed."
# Make sure that the service is up after installation
service jenkins status
