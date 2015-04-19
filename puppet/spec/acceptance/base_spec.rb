require 'spec_helper_acceptance'

describe 'puppet agent' do

  context 'default parameters' do

    describe package('puppet') do
      it { should be_installed }
    end

    describe service('puppet') do
      it { should be_enabled }
      #it { is_expected.to be_running }
	  it { should_not be_running }
    end
  end
end
