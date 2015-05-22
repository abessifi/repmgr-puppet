require 'spec_helper_acceptance'

case fact('osfamily')
  when 'Debian'
    pg_service_name = 'postgresql'
end

describe 'repmgr::service class:', :if => SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'services are running by default' do
		it 'should be running' do
      pp = "class { 'repmgr': }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true)
		end
    describe service(pg_service_name) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context 'when service_ensure => stopped' do
    it 'should be stopped' do
      pp = "class { 'repmgr': service_ensure => stopped }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true)
    end
    describe service(pg_service_name) do
      it { should_not be_running }
    end
  end
  #hosts.each do |host|
    # test for master/slave specifications
  #end
end
