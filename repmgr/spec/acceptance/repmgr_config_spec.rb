require 'spec_helper_acceptance'

pg_version = '9.3'

case fact('osfamily')
  when 'Debian'
    pg_config_dir = '/etc/postgresql'
    hba_config_file = "#{pg_config_dir}/#{pg_version}/main/pg_hba.conf"
    pg_config_file  = "#{pg_config_dir}/#{pg_version}/main/postgresql.conf"
end

describe 'repmgr::config class:', :if => SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'default versions of PostgreSQL and repmgr' do
    # Default setup
		it 'sets up the service' do
      pp = "class { 'repmgr': }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true)
		end
    describe file(pg_config_dir) do
      it { should be_directory }
    end
    [hba_config_file, pg_config_file].each do |file_name|
      describe file(file_name) do
        it { should be_file }
      end
    end
    describe port('5432') do
      it { should be_listening }
    end
  end
end
