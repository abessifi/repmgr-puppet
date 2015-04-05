#!/bin/bash

# This is a Bash Script for verifying packages version and installing them.
# It is just quick way to provision Vagrant VMs.

function usage(){
	echo "Usage : ./install_packages.sh <package1> <package2> .."
	exit 1
}

function get_distro_name(){
	which lsb_release >/dev/null || apt-get install -y lsb-release > /dev/null
	echo $(lsb_release -c | awk '{print $2}')
}

function is_installed(){
	package_name=$1
	[ -z $2 ] && package_version="" || package_version=$2
	current_name=$(dpkg-query -W -f='${Status}' $package_name)
	current_version=$(dpkg-query -W -f='${Version}' $package_name)
	# Check if $1 package is already installed
	if [[ "$current_name" == "install ok installed" && \
		`echo $current_version | egrep "^${package_version}"` ]]; then
		echo "${package_name} ${current_version} is already installed !"
		return 0
	fi
	return 1
}

function install_puppet(){
	# Download puppetlabs-release-<debian-release>.deb
	puppet_binary=$1
	puppet_version=$2
	DEBIAN_RELEASE=$(get_distro_name)
	puppet_package=puppetlabs-release-${DEBIAN_RELEASE}.deb
	tmp_file=/tmp/${puppet_package}
	wget --output-document=${tmp_file} https://apt.puppetlabs.com/${puppet_package}
	if [ -f ${tmp_file} ]; then
		# Install the $puppet_package which will setup the puppet repos entries in /etc/apt/sources.list.d/puppetlabs.list file.
		sudo dpkg -i $tmp_file
		sudo apt-get update
		# Install puppet/puppetmaster package
		[ "$puppet_binary" == "puppet" ] && sudo apt-get install -y \
			puppet-common=${puppet_version} puppet=${puppet_version}
		[ "$puppet_binary" == "puppetmaster" ] && sudo apt-get install -y \
			puppet-common=${puppet_version} puppetmaster-common=${puppet_version} \
			puppetmaster=${puppet_version}
		[ $? -ne 0 ] && echo "Unexpected error occured during installation!" && exit 1
		echo "$puppet_binary '$(puppet --version)' is now installed."
		# Remove the temporary download package
		rm -f $tmp_file
		return 0
	fi
	echo "$tmp_file not found !"
	return 1
}

function install_jenkins(){
	# First add the key to the system
	wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
	# Add the following entry to /etc/apt/sources.list.d/jenkins-ci.list
	sudo echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins-ci.list
	# Update the local package index and install jenkins
	sudo apt-get update
	sudo apt-get install -y jenkins
	[ $? -ne 0 ] && echo "Unexpected error occured during installation!" && exit 1
	echo "Jenkins $(dpkg-query -W -f='${Version}' jenkins) is now installed."
}

function check_service(){
	service=$1
	sudo /etc/init.d/${service} status
	# Try to start $service if it is down by default
	if [ $? -ne 0 ];then
		sudo /etc/init.d/${service} start || return 1
	fi
}

function install_utilities(){
	which bundle > /dev/null || sudo gem install bundler
	sudo apt-get install -y git
}

# Check and Install packages
[ "$#" -eq 0 ] && usage

DEBIAN_RELEASE=""

for package in "$@"; do
	case "$package" in
		"puppet")
			is_installed "puppet" "3.7.4" || install_puppet "puppet" "3.7.4-1puppetlabs1"
			;;
		"puppetmaster") 
			is_installed "puppetmaster" "3.7.4" || install_puppet "puppetmaster" "3.7.4-1puppetlabs1"
			check_service "puppetmaster"
			install_utilities
			;;
		"jenkins")
			is_installed "jenkins" || install_jenkins
			check_service "jenkins"
			;;
		*) usage ;;
	esac
done


