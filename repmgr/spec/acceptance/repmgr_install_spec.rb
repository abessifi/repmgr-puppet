require 'spec_helper_acceptance'

repmgr_version = '3.0'
repmgr_package_name = 'repmgr'
pg_version = '9.3'
pg_package_name = "postgresql"
pg_supported_versions = case repmgr_version
  when '2.0' then ['9.1', '9.2']
  when '3.0' then ['9.3', '9.4']
  else '9.1'
end

case fact('osfamily')
  when 'Debian'
    pg_package_name = "postgresql-#{pg_version}"
    pg_data_dir = "/var/lib/postgresql/#{pg_version}/main"
    repmgr_package_name = "postgresql-#{pg_version}-repmgr"
    repmgr_cli_bin = "/usr/lib/postgresql/#{pg_version}/bin/repmgr"
    repmgr_daemon_bin = "/usr/lib/postgresql/#{pg_version}/bin/repmgrd"
end

repmgr_initscript = '/etc/init.d/repmgrd'

describe 'repmgr::install class:', :if => SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'default versions of PostgreSQL and repmgr' do
    # Default setup
    it 'should succeed' do
      pp = "class { 'repmgr': }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true)
    end
    it 'is a supported PostgreSQL version' do
      expect(pg_supported_versions).to include(pg_version)
    end
    describe package(pg_package_name) do
      it { should be_installed }
    end
    describe user('postgres') do
      it { should exist }
    end
    describe file(pg_data_dir) do
      it { should be_directory }
    end
    describe package(repmgr_package_name) do
      it { should be_installed }
    end
    [repmgr_cli_bin, repmgr_daemon_bin].each do |bin_name|
      describe file(bin_name) do
        it { should be_executable.by_user('root') }
      end
    end
    describe file(repmgr_initscript) do
      it { should be_executable }
    end
    #hosts.each do |host|
      # test for master/slave specifications
    #end
  end
end
