require 'spec_helper'

describe 'repmgr::buildsource', :type => :class do
  context 'when url param is undef' do
    it { is_expected.to raise_error(Puppet::Error, /Repmgr source archive url not specified !/) } 
  end

  context 'invalid source archive url' do
    let(:params) {{ :url => 'foo.bar.baz' }}
    it { is_expected.to raise_error(Puppet::Error, /Invalid url 'foo.bar.baz'/) }
  end

  context 'unknown source archive format' do
    let(:params) {{ 
      :url => 'https://github.com/2ndQuadrant/repmgr/archive/REL3_0_STABLE.zip',
      :pkg_format => 'rar',
    }}
	  it { is_expected.to raise_error(Puppet::Error, /Archive type 'rar' not supported/) }
  end
  
  context 'unsupported Linux platform' do
    let(:facts) {{ :osfamily => 'Foobar' }}
    let(:params) {{ 
      :url => 'https://github.com/2ndQuadrant/repmgr/archive/REL3_0_STABLE.zip',
      :pkg_format => 'zip',
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
      :pkg_format => 'zip',
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
