require 'spec_helper_acceptance'

case fact('osfamily')
  when 'Debian'
    pg_version = debian_pg_version_helper
    pg_package_name = "postgresql-#{pg_version}"
    pg_data_dir = "/var/lib/postgresql/#{pg_version}/main"
  else
    # TODO what about other OSes
    pg_package_name = "postgresql"
end

describe 'repmgr::install class:', :if => SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  describe 'PostgreSQL server' do
    it 'installs the default version' do
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
