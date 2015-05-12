require 'spec_helper_acceptance'

describe 'puppet agent' do
  describe package('puppet') do
    it { should be_installed }
  end
  describe service('puppet') do
    it { should be_enabled }
    it { should_not be_running }
  end
end

describe 'ntp server' do
  it 'should run successfully' do
	pp = "class { 'ntp': }"
	# Run it twice and test for idempotency.
	apply_manifest(pp, :catch_failures => true)
	apply_manifest(pp, :catch_changes => true)
  end
  describe package('ntp') do
    it { should be_installed }
  end
  describe service('ntp') do
    it { should be_running }
  end
  describe file('/etc/ntp.conf') do
	it { should be_file }
  end
end
