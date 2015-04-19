# == Class repmgr::params
#
# This class is meant to be called from repmgr.
# It sets variables according to platform.
#

class repmgr::params{

    case $::osfamily {
        debian: {
            case $::lsbdistcodename {
                'wheezy': {
                    # packages
                    $postgresql = 'postgresql-9.1'
                    $postgresql_contrib = 'postgresql-contrib-9.1' 
                    $postgresql_server_dev = 'postgresql-server-dev-9.1'
                    # config dirs and files
                    $pg_home_dir = '/var/lib/postgresql'
                    $pg_data = '/var/lib/postgresql/9.1/main'
                    $pg_config_dir = '/etc/postgresql/9.1/main'
                    $pg_config_file = '/etc/postgresql/9.1/main/postgresql.conf'
                    $pg_logfile = '/var/log/postgresql/postgresql-9.1-main.log'
                    $repmgr_conf_file = '/etc/repmgr/repmgr.conf'
                    $repmgrd_log_dir = '/var/log/repmgr'
                    # bins and scripts
                    $pg_bin_dir = '/usr/lib/postgresql/9.1/bin'
                    $pg_ctl = '/usr/lib/postgresql/9.1/bin/pg_ctl'
                    $pg_contrib_dir = '/usr/share/postgresql/9.1/contrib'
                }
                default: {
                    fail("Repmgr works with PostgreSQL versions 9.0 and superior which are available in Debian 7 and latest versions")
                }
            }
        }
        default: {
            fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
    }
}
