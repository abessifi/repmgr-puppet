require 'spec_helper_acceptance'

case fact('osfamily')
  when 'Debian'
    # On Debian OSes, Puppet didn't install the 'postgresql' package. Instead it 
    # searches for a postgresql-{version} package and tries to install it.
    # Here we declare the default available PostgreSQL version on the main APT repo
    # of some releases.
    if fact('operatingsystem') == 'Debian'
      case fact('lsbdistcodename')
        when 'jessie'
          pg_package_name = 'postgresql-9.4'
        when 'wheezy'
          pg_package_name = 'postgresql-9.1'
      end
    end
    if fact('operatingsystem') == 'Ubuntu'
      case fact('lsbdistcodename')
        when 'trusty'
          pg_package_name = 'postgresql-9.3'
      end
    end
    pg_version = command('ls /etc/postgresql/').stdout.chomp
    pg_home_dir = '/var/lib/postgresql'
    pg_data_dir = "#{pg_home_dir}/#{pg_version}/main"
  else
    # TODO what about other OSes
    pg_package_name = "postgresql"
end

describe 'repmgr::install class:', :if => SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  describe 'PostgreSQL server' do
    it 'installs the postgresql package' do
      pp = "class { 'repmgr': }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true)
    end

    describe package(pg_package_name) do
      it { should be_installed }
    end

    describe user('postgres') do
      it { should exist }
    end

    describe file("#{pg_data_dir}") do
      it { should be_directory }
    end
    #hosts.each do |host|
      # test for master/slave specifications
    #end
  end
end
