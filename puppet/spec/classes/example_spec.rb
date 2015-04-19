require 'spec_helper'

describe 'puppet' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "puppet class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('puppet::params') }
          it { is_expected.to contain_class('puppet::install').that_comes_before('puppet::config') }
          it { is_expected.to contain_class('puppet::config') }
          it { is_expected.to contain_class('puppet::service').that_subscribes_to('puppet::config') }

          it { is_expected.to contain_service('puppet') }
          it { is_expected.to contain_package('puppet').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'puppet class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('puppet') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
