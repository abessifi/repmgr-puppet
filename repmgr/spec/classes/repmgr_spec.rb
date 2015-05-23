require 'spec_helper'

describe 'repmgr', :type => :class do
  let(:facts) {{ :concat_basedir => '/foo' }}
  context 'supported operating systems' do
    SUPPORTED_PLATFORMS.each do |platform|
      if platform == 'Debian'
        let :facts do
          super().merge({ :osfamily => platform,
                          :lsbdistid => 'Debian',
                          :operatingsystem => 'Debian',
                          :operatingsystemrelease => '7.0',
                          :lsbdistcodename => 'wheezy',
          })
        end
      else
        let(:facts) {{ :osfamily => platform }}
      end

      context "repmgr class without any parameters" do
        let(:params) {{ }}
        it { is_expected.to contain_class('repmgr').with(
          'package_manage' => 'true',
        )}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('repmgr::params') }
        it { is_expected.to contain_class('repmgr::install').that_comes_before('repmgr::config') }
        it { is_expected.to contain_class('repmgr::config') }
        it { is_expected.to contain_class('repmgr::service').that_subscribes_to('repmgr::config') }
      end

      describe 'repmgr::params' do
        context 'package_name => postgresql-rempgr' do
          let(:params) {{
            :package_name => 'postgresql-rempgr',
            :package_manage => true,
          }}
          it 'should fail if package_name => postgresql-rempgr' do
            is_expected.to raise_error(Puppet::Error, /Incorrect repmgr package name 'postgresql-rempgr'/)
          end
        end

        context 'when pg_version => 9.1.0' do
          let(:params) {{ :pg_version => '9.1.0' }}
          it 'should fail if PostgreSQL version format is incorrect' do
            is_expected.to raise_error(Puppet::Error, /Unknown PostgreSQL version format '9.1.0'/)
          end
        end

        context 'when build_source => true' do
          let(:params) {{ :build_source => true }}
          it 'should fail' do
			    is_expected.to raise_error(Puppet::Error, /You are trying to build repmgr from sources. Please set the rempgr version !/)
          end
        end

        context 'when source_archive_url is undef' do
          let(:params) {{
            :build_source => true,
            :version => '3.0',
          }}
          it { is_expected.to raise_error(Puppet::Error, /Cannot find the rempgr source archive url/) } 
        end
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
      it 'should fail' do
        is_expected.to raise_error(Puppet::Error, /Unsupported platform: Solaris\/Nexenta/)
      end
    end
  end

  describe 'repmgr::install', :type => :class do
    let :facts do
	    super().merge({
        :osfamily => 'Debian',
        :lsbdistid => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => '7.0',
        :lsbdistcodename => 'wheezy',
      })
    end
    
    context 'default versions of PostgreSQL and repmgr'  do
      it { is_expected.to contain_class('postgresql::server').that_comes_before('Package[postgresql-9.3-repmgr]') }
      it { is_expected.to contain_class('postgresql::globals').that_comes_before('postgresql::server') }
      it { is_expected.to contain_package('postgresql-9.3-repmgr').with('ensure' => 'present') }
    end

    context 'when build_source => true' do
      let(:params) {{
		    :build_source => true,
		    :version => '3.0',
        :source_archive_url => 'https://github.com/2ndQuadrant/repmgr/archive/REL3_0_STABLE.zip',
	    }}
      it { is_expected.to contain_class('repmgr::buildsource') }
    end
  end
end

