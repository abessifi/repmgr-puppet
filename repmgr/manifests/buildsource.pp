# == Class repmgr::buildsource
#
# This class is called from repmgr::install to build and install
# repmgr from sources.
#

class repmgr::buildsource (
  $url = undef,
  $version = '3.0',
  $pkg_format = 'tar',
  $build_dir_path = '/usr/local/src',
){

  if $url {
    validate_re($url, '^(http|https)://[\S]+', "Invalid url '${$url}'")
  }
  else {
    fail('Repmgr source archive url not specified !')
  }
  validate_absolute_path($build_dir_path)
  
  unless $pkg_format in ['tar', 'zip', 'bzip'] {
    fail("Archive type '${pkg_format}' not supported.")
  }
  $archive_name = basename($url)
  $src_folder_name = "repmgr-${version}"
  $archive_extension = $pkg_format ? {
    'tar' => '.tar.gz',
    'zip' => '.zip',
    'bzip' => '.tar.bz2',
  }
  $extract_cmd = $pkg_format ? {
    'tar'  => "tar -xzf ${archive_name} -C ${src_folder_name}\
    --strip-components 1",
    'zip'  => "unzip -q -d ${src_folder_name} ${archive_name}",
    'bzip' => "tar -xjf ${archive_name} -C ${src_folder_name}\
    --strip-components 1",
  }
  # Determin make_cmd and install_cmd values according to ::osfamily.
  case $::osfamily {
    'Debian': {
      $package_name = 'postgresql-repmgr-*.deb'
      $make_cmd     = 'make USE_PGXS=1 deb'
      $install_cmd  = "dpkg -i ${package_name}"
    }
    default: {
      fail("Unsupported Linux platform '${::osfamily}'.")
    }
  }
  # Setup some Exec default params.
  Exec {
    user    => 'root',
    cwd     => $build_dir_path,
    timeout => '0',
    path    => '/usr/bin:/sbin/:/bin',
  }
  # Download the source archive.
  exec { 'download_sources':
    command => "wget -q ${url}",
    before  => Exec['extract_sources'],
  }
  # Extract the archive sources.
  exec { 'extract_sources':
    command => "mkdir -p ${src_folder_name} && ${extract_cmd}",
    onlyif  => "test -f ${archive_name}",
    before  => Exec['make'],
  }
  # Build the deb/rpm package.
  exec { 'make':
    cwd     => "${build_dir_path}/${src_folder_name}",
    command => $make_cmd,
    #onlyif  => "test -d ${src_folder_name}",
    before  => Exec['install'],
  }
  # Install the deb/rpm package.
  exec { 'install':
    command => $install_cmd,
    before  =>  Exec['clean'],
  }
  # Remove the source directory.
  exec { 'clean':
    command => "rm -rf ${archive_name} ${package_name} ${src_folder_name}",
  }
}
