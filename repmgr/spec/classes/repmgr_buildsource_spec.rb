require 'spec_helper'

describe 'repmgr::buildsource', :type => :class do

  context 'when version is invalid' do
    let(:params) {{
      :version => '3.0.1',	
      :url => 'https://github.com/2ndQuadrant/repmgr/archive/REL3_0_STABLE.zip',
    }}
    it { is_expected.to raise_error(Puppet::Error, /Unknown repmgr version format '3.0.1'/) }
  end

  context 'when url is invalid' do
    let(:params) {{ :url => 'foo.bar.baz' }}
    it { is_expected.to raise_error(Puppet::Error, /Invalid url 'foo.bar.baz'/) }
  end

  context 'when pkg_format is not supported' do
    let(:params) {{
	    :version => '3.0',	
      :url => 'https://github.com/2ndQuadrant/repmgr/archive/REL3_0_STABLE.rar',
    }}
	  it { is_expected.to raise_error(Puppet::Error, /Archive type not supported/) }
  end
  
  context 'when Linux platform is not supported' do
    let(:facts) {{ :osfamily => 'Foobar' }}
    let(:params) {{
	    :version => '3.0',	
      :url => 'https://github.com/2ndQuadrant/repmgr/archive/REL3_0_STABLE.zip',
    }}
    it { is_expected.to raise_error(Puppet::Error, /Unsupported Linux platform 'Foobar'/) }
  end

  context 'on a Debian distribution' do
    let(:facts) {{
      :osfamily => 'Debian',
      :lsbdistid => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '7.0',
      :lsbdistcodename => 'wheezy',
    }}
    let(:params) {{
      :url => 'https://github.com/2ndQuadrant/repmgr/archive/REL3_0_STABLE.zip',
	    :version => '3.0',
      :build_dir_path => '/usr/local/src',
    }}
    it { is_expected.to contain_exec('download_sources').with_command('wget -q https://github.com/2ndQuadrant/repmgr/archive/REL3_0_STABLE.zip') }
    it { is_expected.to contain_exec('download_sources').that_comes_before('Exec[extract_sources]') }
    it { is_expected.to contain_exec('extract_sources').with_command('mkdir -p repmgr-3.0 && unzip -q -d repmgr-3.0 REL3_0_STABLE.zip') }
    it { is_expected.to contain_exec('extract_sources').that_comes_before('Exec[make]') }
    it { is_expected.to contain_exec('make').with_command('make USE_PGXS=1 deb') }
    it { is_expected.to contain_exec('make').that_comes_before('Exec[install]') }
    it { is_expected.to contain_exec('install').with_command('dpkg -i postgresql-repmgr-*.deb') }
    it { is_expected.to contain_exec('install').that_comes_before('Exec[clean]') }
    it { is_expected.to contain_exec('clean').with_command('rm -rf REL3_0_STABLE.zip postgresql-repmgr-*.deb repmgr-3.0') }
  end
end
