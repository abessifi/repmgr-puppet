#!/bin/bash
#
# DESCRIPTION
# 	This shell script is used to :
# 	- simplify the repmgr module dependencies installation.
# 	- automate running tests (unittests, acceptance).
# 	- what else ?
#
# SYNOPSIS
# 	./run_tests.sh [OPTIONS]
#
# OPTIONS
#   Generic Script Information
#
# 	-a, --acceptance-tests
# 		Run acceptance tests. This calls beaker which will spin up a Vagrant VM(s) to run tests on.
#
#   -c CONFIG_FILE, --config=CONFIG_FILE
# 		CONFIG_FILE is a YAML file name (without .yaml or .yml extension) under 
# 					spec/acceptance/nodesets/ directory. This file defines each 
# 					node in the test configuration.
# 	-d,--no-destroy
# 		Preserve test boxes after testing.
#
# 	-p,--no-provision
# 		Skip provisioning boxes before testing, will then assume that boxes are
# 		already provisioned and reachable.
#
# 	-t, --tests
# 		Run all tests.
#
# 	-u, --unit-tests
#		Run unittests. This runs Rspec againt all spec/classes/*_spec.rb files.
#
# EXAMPLES
# 	To run all tests with default parameters:
# 		./run_tests.sh --tests
# 	
# 	Tu run all tests with a specific environment configuration:
# 		./run_tests.sh --tests --config=debian-76-x64
# 	
# 	To run only acceptance tests with a specific environment configuration:
# 		./run_tests.sh --acceptance-tests --config=debian-76-x64
#
# 	To run only unittests:
# 		./run_tests.sh --unittests
#
# 	To provision the box, preserve it and run tests:
# 		./run_tests.sh --tests --no-destroy
#
# 	To re-use the same box, preserve it and run tests:
# 		./run_tests.sh --tests --no-destroy --no-destroy
#

set -e

REQUIRED_RUBY_VERSION='1.9.3'
PUPPET_MODULE='repmgr'
SPEC_DIR="$PUPPET_MODULE/spec"
DEFAULT_ENVIRONMENT_CONFIG='default'
RUN_ALL_TESTS='no'
RUN_ACCEPTANCE_TESTS='no'
RUN_UNIT_TESTS='no'
BEAKER_DESTROY='yes'
BEAKER_PROVISION='yes'

function usage(){
	echo "Usage: $0 [OPTIONS]

 OPTIONS
   Generic Script Information:
	
	-a, --acceptance-tests
 		Run acceptance tests. This calls beaker which will spin up a Vagrant VM(s)
		to run tests on.
	
	-c CONFIG_FILE, --config=CONFIG_FILE
 		CONFIG_FILE is a YAML file name (without .yaml or .yml extension) under 
 		spec/acceptance/nodesets/ directory. This file defines each node in the
		test configuration.
	
 	-d,--no-destroy
 		Preserve test boxes after testing.

 	-p,--no-provision
		Skip provisioning boxes before testing, will then assume that boxes are
		already provisioned and reachable.

	-t, --tests
 		Run all tests.
	
	-u, --unit-tests
		Run unittests. This runs Rspec againt all spec/classes/*_spec.rb files.

 EXAMPLES
	Tu run all tests with a specific environment configuration:
		./run_tests.sh --tests --config=debian-76-x64
 	
	To run only acceptance tests with a specific environment configuration:
		./run_tests.sh --acceptance-tests --config=debian-76-x64
	"
	exit 1
}
# quit if not argument is passed
[ "$#" == 0 ] && usage

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
	echo "[WARN] The required ruby version '${REQUIRED_RUBY_VERSION}' is not set up !"
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
	echo "[INFO] Ruby '${REQUIRED_RUBY_VERSION}' is now the default version."
}

# Install repmgr-puppet module dependencies
function install_module_requirements(){
	echo "[INFO] Install required gems.."
	bundle install --gemfile repmgr/Gemfile
}

# TODO: determine required packages on openSuse and CentOS distros.
function install_requirements(){
	# Install the correct ruby version
	get_system_ruby_version || install_ruby
	# Install lsb-release with the appropriate package manage
	# openSuse
	# which zypper && zypper install lsb-release
	# RedHat based distros : CentOS, Fedora
	which yum > /dev/null && yum install lsb-release > /dev/null
	# Debian based ditros : Debian, Ubuntu, etc
	which apt-get > /dev/null && apt-get install -y lsb-release > /dev/null
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
	echo "[INFO] Check if bundler is installed.."
	which bundle > /dev/null || sudo gem install bundler
	# Install all required gems
	install_module_requirements
}
# Run integration/acceptance tests
function run_acceptance_tests(){
    # Use DEFAULT_ENVIRONMENT_CONFIG if ENVIRONMENT_CONFIG not set.
	[ -z "$ENVIRONMENT_CONFIG" ] && ENVIRONMENT_CONFIG=$DEFAULT_ENVIRONMENT_CONFIG
	echo "[INFO] Running acceptance tests.."
	# Check BEAKER environment parameters
	ENVIRONMENT_CONFIG_FILE="${SPEC_DIR}/acceptance/nodesets/${ENVIRONMENT_CONFIG}.yml"
	if [[ -z "$ENVIRONMENT_CONFIG" || ! -f "$ENVIRONMENT_CONFIG_FILE" ]]; then
		echo "[ERROR] '$ENVIRONMENT_CONFIG_FILE' not found !"
		exit 1
	fi
	cd $PUPPET_MODULE
	# Run tests
	BEAKER_set=$ENVIRONMENT_CONFIG BEAKER_destroy=$BEAKER_DESTROY BEAKER_provision=$BEAKER_PROVISION \
		bundle exec rake acceptance
	cd ..
}
# Run unittests
function run_unittests(){
	echo "[INFO] Running unittests.."
	echo "Not yet ready !"
	#bundle exec rake test
}

# Otherwise, parse options
OPTS=$(getopt -o acd:ptu --long acceptance-tests,config:,no-destroy,tests,no-provision,unit-tests -n "$0" -- "$@") || usage
eval set -- "$OPTS"

while true ; do
	case "$1" in
		-c|--config)
			case "$2" in
                *) ENVIRONMENT_CONFIG="$2"
				   shift 2 ;;
			esac
			;;
		-a|--acceptance-tests)
			RUN_ACCEPTANCE_TESTS='yes'
			shift
			;;
		-d|--no-destroy)
			BEAKER_DESTROY='no'
			shift;;
		-p|--no-provision)
			BEAKER_PROVISION='no'
			shift;;
		-u|--unit-tests)
			RUN_UNIT_TESTS='yes'
			shift
			;;
		-t|--tests)
			RUN_ALL_TESTS='yes'
			shift
			;;
		--) shift ; break ;;
		*)	usage ;;
	esac
done

# Install required system packages and Ruby gems
install_requirements
# If no test options, run all stuff with default parameters
if [ "$RUN_ALL_TESTS" == 'yes' ]; then
	run_acceptance_tests
	run_unittests
	exit 0
fi
# Run tests according to specified flags
[ "$RUN_ACCEPTANCE_TESTS" == 'yes' ] && run_acceptance_tests || true
[ "$RUN_UNIT_TESTS" == 'yes' ] && run_unittests || true

exit 0
