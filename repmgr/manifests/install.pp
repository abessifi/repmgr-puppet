# == Class repmgr::install
#
# This class is called from repmgr for install.
#

class repmgr::install inherits repmgr {

  if $repmgr::package_ensure == 'present' {
    # Install PostgreSQL server.
    class { 'postgresql::globals':
      manage_package_repo => $repmgr::package_manage,
      version             => $repmgr::pg_version,
    }->
    class { 'postgresql::server':
      package_ensure => 'present',
      service_ensure => $repmgr::service_ensure,
    }
    # Install repmgr package from sources.
    if $repmgr::build_source {
      # Install some required packages for build.
      package { $repmgr::build_depends:
        ensure  => 'present',
        require => Class['postgresql::server'],
      }->
      class { 'repmgr::buildsource':
        url     => $repmgr::source_archive_url,
        version => $repmgr::version,
      }
    }
    else {
      # Install repmgr package from pre-build package.
      package { $repmgr::package_name:
        ensure  => 'present',
        require => Class['postgresql::server'],
      }
    }
  }

  elsif $repmgr::package_ensure in ['absent', 'purged'] {
    package { [ $repmgr::package_name, 'repmgr-auto', 'repmgr-common' ]:
      ensure => $repmgr::package_ensure
    }->
    class { 'postgresql::globals':
      version => $repmgr::pg_version,
    }->
    class {'postgresql::server':
      package_ensure => $repmgr::package_ensure
    }
  }
}
