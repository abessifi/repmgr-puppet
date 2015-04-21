require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

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

# Actually this module is juste tested on Debian
UNSUPPORTED_PLATFORMS = [ 'suse', 'fedora', 'oracle', 'scientific', 'sles', 'ubuntu', 'windows', 'solaris', 'aix', 'el' ]

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
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
	  on host, puppet('module', 'install', 'puppetlabs-ntp'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
