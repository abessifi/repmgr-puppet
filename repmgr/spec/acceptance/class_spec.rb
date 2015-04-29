require 'spec_helper_acceptance'

describe 'repmgr class:', :if => SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'should run successfully' do
    pp = "class { 'repmgr': }"

    # Apply twice to ensure no errors the second time.
    apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true) do |r|
      expect(r.stderr).not_to match(/error/i)
    end
    apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true) do |r|
      expect(r.stderr).not_to eq(/error/i)
      expect(r.exit_code).to be_zero
    end
  end

  context 'ensure => stopped:' do
    it 'runs successfully' do
      pp = "class { 'repmgr': service_ensure => stopped }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true) do |r|
        expect(r.stderr).not_to match(/error/i)
      end
    end
  end

  context 'ensure => running:' do
    it 'runs successfully' do
      pp = "class { 'repmgr': service_ensure => running }"
      apply_manifest(pp, :modulepath => MODULEPATH, :catch_failures => true) do |r|
        expect(r.stderr).not_to match(/error/i)
      end
    end
  end
end
