require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

# Actually this module is juste tested on Debian
SUPPORTED_PLATFORMS = [ 'Debian' ]
SUPPORTED_DEBIAN_DIST = [ 'Debian', 'Ubuntu' ]
MODULEPATH = '/etc/puppet/modules:/etc/puppet/modules/repmgr/modules'
PUPPETFILE_PATH = '/etc/puppet/modules/repmgr/Puppetfile'

def debian_pg_version_helper
  # On Debian OSes, Puppet didn't install the 'postgresql' package. Instead it 
  # searches for a postgresql-{version} package and tries to install it.
  # Here we declare the default available PostgreSQL version on the main APT repo
  # of some releases.
  if fact('operatingsystem') == 'Debian'
    case fact('lsbdistcodename')
      when 'jessie'
        pg_version = '9.4'
      when 'wheezy'
        pg_version = '9.1'
    end
  end
  if fact('operatingsystem') == 'Ubuntu'
    case fact('lsbdistcodename')
      when 'trusty'
        pg_version = '9.3'
    end
  end
  pg_version
end

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  # Readable test descriptions
  c.formatter = :documentation
  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'repmgr')
    hosts.each do |host|
	  # Install r10k
	  # TODO test for compatibility with other platforms
      on host, shell("which r10k || gem install r10k"), { :acceptable_exit_codes => 0 }
	  on host, shell("PUPPETFILE=#{PUPPETFILE_PATH} r10k puppetfile install --verbose"),
		  { :acceptable_exit_codes => 0 }
	  on host, puppet('module', 'install', 'puppetlabs-ntp'), 
		  { :acceptable_exit_codes => [0,1] }
    end
  end
end
