# == Class puppet::install
#
# This class is called from repmgr for install.
#

class repmgr::install inherits repmgr {
  # Install PostgreSQL server
  class { 'postgresql::globals':
    manage_package_repo => $repmgr::package_manage,
    version             => $repmgr::pg_version,
  }->
  class { 'postgresql::server':
    package_ensure => $repmgr::package_ensure,
    service_ensure => $repmgr::service_ensure,
    before         => Package[$repmgr::package_name],
  }
  # Install repmgr package
  package { $repmgr::package_name:
    ensure => 'present'
  }
}
