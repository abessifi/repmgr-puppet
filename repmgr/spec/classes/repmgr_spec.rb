require 'spec_helper'

SUPPORTED_PLATFORMS = [ 'Debian' ] 

describe 'repmgr', :type => :class do
  let(:facts) {{ :concat_basedir => '/foo' }}
  context 'supported operating systems' do
    SUPPORTED_PLATFORMS.each do |platform|
      if platform == 'Debian'
        let :facts do
          super().merge({ :osfamily => platform,
                          :operatingsystem => 'Debian',
                          :operatingsystemrelease => 'wheezy'
          })
        end
      else
        let(:facts) {{ :osfamily => platform }}
      end

      context "repmgr class without any parameters" do
        let(:params) {{ }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('repmgr::params') }
        it { is_expected.to contain_class('repmgr::install').that_comes_before('repmgr::config') }
        it { is_expected.to contain_class('repmgr::config') }
        it { is_expected.to contain_class('repmgr::service').that_subscribes_to('repmgr::config') }
      end
    end
  end

  context 'unsupported Debian distribution' do
    let :facts do
      super().merge({ :osfamily => 'Debian', :operatingsystem => 'Mint'})
    end

    it 'should fail' do
      is_expected.to raise_error(Puppet::Error, /Unsupported Debian distribution/)
    end
  end

  context 'unsupported operating system' do
    describe 'repmgr class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it 'should faild' do
        is_expected.to raise_error(Puppet::Error, /Unsupported platform: Solaris\/Nexenta/)
      end
    end
  end

  describe 'repmgr::install', :type => :class do
    let :facts do
	    super().merge({
        :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => 'wheezy',
      })
    end

    describe  'PostgreSQL server'  do
      it { is_expected.to contain_class('postgresql::server') }
      it { is_expected.to contain_class('postgresql::globals').that_comes_before('postgresql::server') }
    end
  end

end

