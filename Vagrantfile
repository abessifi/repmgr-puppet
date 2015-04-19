# -*- mode: ruby -*-
# vi: set ft=ruby :

PG_TOTAL_SLAVES = 2
DOMAIN = "cllfst.local"
FIRST_NODE_IP = "192.168.40.10"
PUPPET_MASTER_IP = "192.168.40.100"
JENKINS_IP = "192.168.40.101"

ip_last_byte = FIRST_NODE_IP.split(".")[-1].to_i
pg_slaves = []

(1..PG_TOTAL_SLAVES).each { |id|
	ip_last_byte +=1
	pg_slaves << {:hostname => "pg-slave-#{id}", :ip => "192.168.40.#{ip_last_byte}"}
}

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	# Debian boxes are available in https://vagrantcloud.com/deb
	# Actual stable release is Debian Wheezy
	config.vm.box = "deb/wheezy-amd64"
	# Disable automatique box update
	config.vm.box_check_update = false
	# Disabling the default /vagrant share
	config.vm.synced_folder ".", "/vagrant" , disabled: true
	# Update /etc/hosts in all VMs
	config.hostmanager.enabled = true
	config.hostmanager.manage_host = true
	config.hostmanager.include_offline = true
	# PostgreSQL master VM
	config.vm.define "pg-master" do |cfg|
		cfg.vm.hostname = "pg-master.#{DOMAIN}"
		cfg.vm.network "private_network", ip: FIRST_NODE_IP
		cfg.hostmanager.aliases = "pg-master"
		cfg.vm.provider "virtualbox" do |v|
			v.name = "pg-master"
			v.memory = 768
		end
		cfg.vm.provision "shell", :path => "./scripts/install_packages.sh", :args => "puppet"
	end
	# PostgreSQL slaves VMs definition
	pg_slaves.each do |node|
		config.vm.define node[:hostname] do |cfg|
			cfg.vm.hostname = "#{node[:hostname]}.#{DOMAIN}"
			cfg.vm.network "private_network", ip: node[:ip]
			cfg.hostmanager.aliases = node[:hostname]
			cfg.vm.provider "virtualbox" do |v|
				v.name = node[:hostname]
				v.memory = 512
			end
			cfg.vm.provision "shell", :path => "./scripts/install_packages.sh", :args => "puppet"
		end
	end
	# Puppet master (development VM)
	config.vm.define "puppet-master" do |cfg|
		cfg.vm.hostname = "puppet-master.#{DOMAIN}"
		cfg.vm.network "private_network", ip: PUPPET_MASTER_IP
		cfg.hostmanager.aliases = "puppet-master"
		cfg.vm.provider "virtualbox" do |v| 
			v.name = "puppet-master"
		end
		cfg.vm.provision "shell", :path => "./scripts/install_packages.sh", :args => "puppetmaster"
		cfg.vm.synced_folder "./puppet", "/etc/puppet/environments/development/modules/repmgr"
	end
	# Provision a Jenkins VM to integrate repmgr-puppet module source code.
	config.vm.define "jenkins" do |cfg|
		cfg.vm.hostname = "jenkins.#{DOMAIN}"
		cfg.vm.network "private_network", ip: JENKINS_IP
		# Access Jenkins UI from http://<JENKINS_IP>:8080 or http://localhost:8082
		cfg.vm.network "forwarded_port", guest: 8080, host: 8082
		cfg.hostmanager.aliases = "jenkins"
		cfg.vm.provider "virtualbox" do |v| 
			v.name = "jenkins"
		end
		cfg.vm.provision "shell", :path => "./scripts/install_packages.sh", :args => "jenkins"
	end	
end
