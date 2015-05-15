# == Define: Repmgr
#
# A puppet class for managing streaming replication (SR) in postgresql cluster.
#
# Features:
#  * Deploy postgresql cluster
#
# == Parameters
#
# [*package_ensure*]
#   To manage postgresql and rempgr packages.
#   Can be one of "present" or "absent".
#   Present will install and configure postgresql and repmgr packages..
#   Absent, will simply purge postgresql and repmgr installation.
#   Default to "present".
#
# [*service_ensure*]
#   To manage postgresql and rempgr daemons state.
#   Can be one of "running" or "stopped".
#   Default to "running".
#
# [*pg_version*]
#   The version of PostgreSQL server (supporting Streaming Replication) 
#   to install/manage.
#   Default to "9.3" (the first available PostgreSQL version compatible with
#   repmgr 3.0).
#
# [*package_manage*]
#   To setup the official PostgreSQL repositories on the server. Useful if
#   "pg_version" is not on the default system repositories and you want to
#   install a specific pre-build PostgreSQL and repmgr version.
#   Default to "true".
#
# == Requires:
#   Module dependencies are declared in Puppetfile file.
#
# == Examples
#
#   Init a PostgreSQL server
#   class {'repmgr': }
#
#   Init a custom PostgreSQL server version
#   class {'repmgr':
#      pg_version => '9.4',
#      pg_manage_package_repo => true,
#   }
#
# == Authors
#
# Ahmed Bessifi <ahmed.bessifi@gmail.com>
#
# == Licence
#
# Apache 2.0 - Copyright (C) 2014 Ahmed Bessifi
#

class repmgr (
  $package_name           = $repmgr::params::package_name,
  $package_ensure         = $repmgr::params::package_ensure,
  $package_manage         = $repmgr::params::package_manage,
  $service_ensure         = $repmgr::params::service_ensure,
  $pg_version             = $repmgr::params::pg_version,
) inherits ::repmgr::params {

  # Validate params
  validate_string($package_ensure)
  validate_string($service_ensure)
  validate_bool($package_manage)
  if $pg_version {
    validate_re($pg_version,'^\d.\d$',
    "Unknown PostgreSQL version format '${pg_version}'")
  }
  if $package_manage and ($::osfamily == 'Debian') {
    validate_re($package_name, '^postgresql-\d.\d-repmgr$',
    "Incorrect repmgr package name '${package_name}'")
  }

  class { '::repmgr::install':
  }->
  class { '::repmgr::config':
  }~>
  class { '::repmgr::service':
  }
}

