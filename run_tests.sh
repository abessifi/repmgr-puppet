#!/bin/bash

function install_requirements(){
	bundle install
}

function run_serversperc(){
	cd serverspec/
	# The following commands replace 'rake serverspec:all' which didn't run
	# as expected.
	rake serverspec:pg-master
	rake serverspec:pg-slave-1
	rake serverspec:pg-slave-2
	cd ..
}

install_requirements
run_serversperc

