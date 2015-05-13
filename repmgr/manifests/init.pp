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
#   Default to "undef" (install the default available PostgreSQL version).
#
# [*pg_manage_package_repo*]
#   To setup the official PostgreSQL repositories on the server. Useful if
#   "pg_version" is not on the default system repositories.
#   Default to "false".
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
  $package_ensure         = $repmgr::params::package_ensure,
  $service_ensure         = $repmgr::params::service_ensure,
  $pg_version             = $repmgr::params::pg_version,
  $pg_manage_package_repo = $repmgr::params::pg_manage_package_repo,
) inherits ::repmgr::params {

  # Validate params
  validate_string($package_ensure)
  validate_string($service_ensure)
  if $pg_version {
    validate_re($pg_version,'^\d+.\d+$',
    "Unknown PostgreSQL version format '${pg_version}'")
  }
  validate_bool($pg_manage_package_repo)

  class { '::repmgr::install':
  }->
  class { '::repmgr::config':
  }~>
  class { '::repmgr::service':
  }
}

