# == Class repmgr::params
#
# This class is meant to be called from repmgr.
# It sets variables according to platform.
#

class repmgr::params{

  # By default use PostgreSQL 9.3 which is compatible with the first version
  # supported by repmgr 3.0.
  $pg_version = '9.3'
  # By default use repmgr 3.0 which supports PostgreSQL 9.4 and 9.3 which and
  # has many usability improvements.
  $package_ensure = 'present'
  $service_ensure = 'running'
  $version = '3.0'
  $build_source = false
  $source_archive_url = 'https://github.com/2ndQuadrant/repmgr/archive/REL3_0_STABLE.tar.gz'

  case $::osfamily {
    'Debian': {
      case $::operatingsystem {
        'Debian', 'Ubuntu': {
          $package_manage =  $::lsbdistcodename ? {
            'wheezy' => true,
            default  => false,
          }
          if $package_manage {
            $package_name = "postgresql-${pg_version}-repmgr"
          }
          else {
            $package_name = 'repmgr'
          }
          $build_depends = [
            'build-essential',
            'libxslt-dev',
            'libxml2-dev',
            'libpam-dev',
            'libedit-dev',
            "postgresql-server-dev-${pg_version}"
          ]
          # packages
          #$postgresql = 'postgresql-9.1'
          #$postgresql_contrib = 'postgresql-contrib-9.1' 
          #$postgresql_server_dev = 'postgresql-server-dev-9.1'
          # config dirs and files
          #$pg_home_dir = '/var/lib/postgresql'
          #$pg_data = '/var/lib/postgresql/9.1/main'
          #$pg_config_dir = '/etc/postgresql/9.1/main'
          #$pg_config_file = '/etc/postgresql/9.1/main/postgresql.conf'
          #$pg_logfile = '/var/log/postgresql/postgresql-9.1-main.log'
          #$repmgr_conf_file = '/etc/repmgr/repmgr.conf'
          #$repmgrd_log_dir = '/var/log/repmgr'
          # bins and scripts
          #$pg_bin_dir = '/usr/lib/postgresql/9.1/bin'
          #$pg_ctl = '/usr/lib/postgresql/9.1/bin/pg_ctl'
          #$pg_contrib_dir = '/usr/share/postgresql/9.1/contrib'
        }
        default: {
            fail('Unsupported Debian distribution.')
        }
      }
    }
    default: {
        fail("Unsupported platform: ${::osfamily}/${::operatingsystem}.")
    }
  }
}
