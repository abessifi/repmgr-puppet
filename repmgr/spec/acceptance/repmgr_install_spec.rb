require 'spec_helper_acceptance'

repmgr_version = '3.0'
repmgr_packages = 'repmgr'
repmgr_built_package_name = 'repmgr-auto'
pg_version = '9.3'
pg_package_name = 'postgresql'
pg_supported_versions = case repmgr_version
  when '2.0' then ['9.1', '9.2']
  when '3.0' then ['9.3', '9.4']
  else '9.1'
end

case fact('osfamily')
  when 'Debian'
    pg_package_name = "postgresql-#{pg_version}"
    pg_data_dir = "/var/lib/postgresql/#{pg_version}/main"
    repmgr_packages = ["postgresql-#{pg_version}-repmgr",'repmgr-common']
    repmgr_cli_bin = "/usr/bin/repmgr"
    repmgr_daemon_bin = "/usr/bin/repmgrd"
end

repmgr_initscript = '/etc/init.d/repmgrd'

shared_examples "repmgr post-install checks" do
  describe package(pg_package_name) do
    it { should be_installed }
  end
  describe user('postgres') do
    it { should exist }
  end
  describe file(pg_data_dir) do
    it { should be_directory }
  end
  [repmgr_cli_bin, repmgr_daemon_bin].each do |bin_name|
    describe file(bin_name) do
      it { should be_executable.by_user('root') }
    end
  end
  describe command("#{repmgr_cli_bin} --version") do
    its(:stdout) { should match /^repmgr/ }
  end
  describe file(repmgr_initscript) do
    it { should be_executable }
  end
end

describe 'repmgr::install class:', :if => SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'default versions of PostgreSQL and repmgr' do
    after(:context) do
      pp = "class { 'repmgr': package_ensure => absent }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true)
    end
  
    it 'should succeed' do
      pp = "class { 'repmgr': }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true)
    end
    it 'is a supported PostgreSQL version' do
      expect(pg_supported_versions).to include(pg_version)
    end
    Array(repmgr_packages).each do |package_name|
      describe package(package_name) do
        it { should be_installed }
      end
    end
    include_examples "repmgr post-install checks"
    #hosts.each do |host|
      # test for master/slave specifications
    #end
  end 
  
  context 'when build_source => true' do
    after(:context) do
      pp = "class { 'repmgr': package_ensure => absent }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true)
    end

    it 'should succeed' do
      pp = "class { 'repmgr': build_source => true }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true)
    end
    describe package(repmgr_built_package_name) do
      it { should be_installed }
    end
    describe package('repmgr-common') do
      it { should_not be_installed }
    end
    include_examples "repmgr post-install checks"
  end
end
