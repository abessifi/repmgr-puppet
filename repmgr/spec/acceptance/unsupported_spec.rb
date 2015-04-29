require 'spec_helper_acceptance'

describe 'unsupported OSes', :unless => SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'should fail' do
    pp = "class { 'repmgr': }"
    expect(apply_manifest(pp, :modulepath => MODULEPATH, :expect_failures => true).stderr).
      to match(/Unsupported platform/i)
  end
end

describe 'Debian family', :if => (fact('osfamily') == 'Debian') do
  describe 'unsupported distributions', :unless => SUPPORTED_DEBIAN_DIST.
    include?(fact('operatingsystem')) do
    it 'should fail' do
      pp = "class { 'repmgr': }"
      expect(apply_manifest(pp, :modulepath => MODULEPATH, :expect_failures => true).stderr).
        to match(/Unsupported Debian distribution/i)
    end
  end
end
