require 'spec_helper_acceptance'

describe 'postgresql server' do

	hosts.each do |host|
	  describe package('postgresql') do
		  it { should be_installed }
	  end

	  describe service('postgresql') do
		  it { should be_enabled }
		  it { should be_running }
	  end

	  describe port('5432') do
		  it { should be_listening }
	  end

	  describe user('postgres') do
		  it { should exist }
	  end
  end
end
