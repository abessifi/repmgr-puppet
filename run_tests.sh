#!/bin/bash

set -e

REQUIRED_RUBY_VERSION='1.9.3'

function get_system_ruby_version(){
	# check if ruby is already installed
	# Return code :
	# 0 => The REQUIRED_RUBY_VERSION is installed.
	# 1 => Ruby is not installed.
	# 2 => Another ruby version is installed.
	echo "[INFO] Check installed ruby version.."
	which ruby > /dev/null || return 1
	ruby --version | cut -d' ' -f2 | egrep -q "^${REQUIRED_RUBY_VERSION}" || return 2
	echo "[INFO] Ruby '${REQUIRED_RUBY_VERSION}' is installed."
}

function install_ruby(){
	# Install ruby with RVM (Ruby Version Manager)
	# Return code :
	# 0 => rvm and ruby are correctly installed
	# 1 => rvm not correctly installed
	echo "[WARN] The required ruby version '${REQUIRED_RUBY_VERSION}' is not installed !"
	# Check if rvm is already installed
	if [ ! -f "/usr/local/rvm/scripts/rvm" ]; then
		# rvm not installed ! install it.
		echo "[INFO] Installing RVM and Ruby '${REQUIRED_RUBY_VERSION}'.."
		# Get a gpg key for a secure communication
		curl -sSL "https://rvm.io/mpapis.asc" | gpg --import - 2> /dev/null
		# Install rvm and the REQUIRED_RUBY_VERSION
		curl -sSL "https://get.rvm.io" | bash -s stable --ruby=$REQUIRED_RUBY_VERSION > /dev/null 
	fi
	source /usr/local/rvm/scripts/rvm || return 1
	# Make sure that REQUIRED_RUBY_VERSION is the default used ruby version.
	rvm current | egrep -q "^ruby-${REQUIRED_RUBY_VERSION}" || rvm use $REQUIRED_RUBY_VERSION --default
	echo "[INFO] Ruby '${REQUIRED_RUBY_VERSION}' is now the default installed version."
}

# TODO: determine required packages on openSuse and CentOS distros.
function install_requirements(){
	# Install the correct ruby version
	get_system_ruby_version || install_ruby
	# Install lsb-release with the appropriate package manage
	# openSuse
	# which zypper && zypper install lsb-release
	# RedHat based distros : CentOS, Fedora
	which yum >/dev/null && yum install lsb-release > /dev/null
	# Debian based ditros : Debian, Ubuntu, etc
	which apt-get >/dev/null && apt-get install -y lsb-release > /dev/null
	LINUX_DISTRO=$(lsb_release -si)
	echo "[INFO] Install Linux required packages.."
	case "$LINUX_DISTRO" in
		"Debian"|"Ubuntu") sudo apt-get install -y gcc g++ ruby-dev libxml2-dev \
			libxslt1-dev zlib1g-dev > /dev/null;;
		"Fedora") sudo yum install make gcc gcc-c++ libxml2-devel libxslt-devel \
			ruby-devel > /dev/null;;
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
	bundle install --gemfile repmgr/Gemfile
}
# Run integration/acceptance tests
function run_acceptance_tests(){
	echo "[INFO] Running acceptance tests.."
	cd repmgr/
	BEAKER_set=repmgr-debian-7-x64 bundle exec rake acceptance
	cd ..
}
# Run unittests
function run_unittests(){
	echo "[INFO] Running unittests.."
	echo "Not yet ready !"
	#bundle exec rake test
}

install_requirements
install_module_requirements
run_acceptance_tests
#run_unittests

