require 'spec_helper_acceptance'

case fact('osfamily')
  when 'Debian'
    pg_service_name = 'postgresql'
end

describe 'repmgr::service class:', :if => SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  describe 'PostgreSQL server' do
		it 'sets up the service' do
      pp = "class { 'repmgr': }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true)
		end

    describe service(pg_service_name) do
      it { should be_enabled }
      it { should be_running }
    end

    describe port('5432') do
      it { should be_listening }
    end

    #hosts.each do |host|
      # test for master/slave specifications
    #end
  end
end
