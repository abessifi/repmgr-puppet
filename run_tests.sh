#!/bin/bash

set -e

# TODO: determine required packages on openSuse and CentOS distros.
function install_requirements(){
	# Install lsb-release with the appropriate package manage
	# openSuse
	# which zypper && zypper install lsb-release
	# RedHat based distros : CentOS, Fedora
	which yum >/dev/null && yum install lsb-release
	# Debian based ditros : Debian, Ubuntu, etc
	which apt-get >/dev/null && apt-get install lsb-release
	LINUX_DISTRO=$(lsb_release -si)
	echo "[INFO] Install Linux required packages"
	case "$LINUX_DISTRO" in
		"Debian"|"Ubuntu") sudo apt-get install -y gcc g++ ruby-dev libxml2-dev libxslt1-dev zlib1g-dev ;;
		"Fedora") sudo yum install make gcc gcc-c++ libxml2-devel libxslt-devel ruby-devel ;;
		*) echo "[ERROR] Unsupported Linux distribution '$LINUX_DISTRO' !"
		   exit 1
		   ;;
	esac
	# Install bundler using ruby gem package installer.
	echo "[INFO] Install bundler using ruby gem package installer.."
	sudo gem install bundler
}
# Install repmgr-puppet module dependencies
function install_module_requirements(){
	echo "[INFO] Install required gems.."
	bundle install --gemfile puppet/Gemfile
}
# Run integration/acceptance tests
function run_acceptance_tests(){
	echo "[INFO] Running acceptance tests.."
	echo "Not yet ready !"
	#bundle exec rake acceptance
}
# Run unittests
function run_unittests(){
	echo "[INFO] Running unittests.."
	echo "Not yet ready !"
	#bundle exec rake test
}

install_requirements
install_module_requirements
run_unittests
#run_acceptance_tests

