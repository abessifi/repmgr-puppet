class repmgr::params{

    case $::osfamily {
        debian: {
            case $::lsbdistcodename {
                'wheezy': {
                    $postgresql = 'postgresql-9.1'
                    $postgresql_contrib = 'postgresql-contrib-9.1' 
                    $postgresql_server_dev = 'postgresql-server-dev-9.1'
                    $pg_config_dir = '/etc/postgresql/9.1/main'
                    $pg_config_file = '/etc/postgresql/9.1/main/postgresql.conf'
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
