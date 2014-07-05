class repmgr::config (

    $node_role = undef,
    $cluster_name = undef,
    $node_id = undef,
    $node_name = undef,
    $conninfo_host = undef,
    $repmgr_ssh_key = undef,
){
    $conninfo_user = 'repmgr'
    $conninfo_dbname = 'repmgr'
    $pg_bindir = '/usr/lib/postgresql/9.1/bin'
    $master_response_timeout = 20
    $reconnect_attempts = 4
    $reconnect_interval = 10
    $failover = 'automatic'
    $promote_command = 'repmgr -f /etc/repmgr/repmgr.conf standby promote'
    $follow_command  = '/var/lib/postgresql/follow_command.sh'
    $loglevel = 'DEBUG'
    $monitor_interval = 5

    $pg_contribdir = '/usr/share/postgresql/9.1/contrib'
    $repmgr_config_file = '/etc/repmgr/repmgr.conf'

    Account['repmgr'] -> File['repmgr_config_file']

    # Create repmgr config dir
    file {'/etc/repmgr':
        ensure => 'directory',
        owner  => root,
        group  => root,
        mode   => '0755',
    }

    # Generate repmgr config file
    file {'repmgr_config_file':
        ensure    => present,
        owner     => repmgr,
        group     => repmgr,
        mode      => '0644',
        content   => template('repmgr/repmgr.conf.erb'),
        path      => $repmgr_config_file,
    }

    # Create repmgr user
    account {'repmgr':
        ensure           => present,
        ssh_keys         => {
            'repmgr_key' => {
                type     => 'ssh-rsa',
                key      => $repmgr_ssh_key,
             }
        }
    }

    # Create the user and database to manage replication
    Exec['create_repmgr_db_user'] -> Exec['create_repmgr_db'] -> Exec['master_register']

    if $node_role == 'master' {
        exec {'create_repmgr_db_user':
            path     => ['/bin/','/usr/bin'],
            command  => 'createuser -s repmgr',
            user     => 'postgres',
            onlyif   => '[ `psql template1 -c "\du" | grep -c repmgr` -eq "0" ]',
        }
        exec{'create_repmgr_db':
            path     => ['/bin', '/usr/bin'],
            command  => "createdb -O repmgr repmgr && psql -f $pg_contribdir/repmgr_funcs.sql repmgr",
            user     => 'postgres',
            onlyif   => '[ `psql -l | grep -c repmgr` -eq "0" ]',
        }

        exec {'master_register':
            path    => ['/bin', '/usr/bin'],
            command => "repmgr -f $repmgr_config_file master register",
            user    => 'postgres',
            onlyif  => [
                "psql -l | grep repmgr",
                "[ `repmgr -f $repmgr_config_file cluster show | grep -c master` -eq 0 ]"
            ],
        }
    }
    elsif $node_role in ['slave', 'witness'] {
        ## Not yet implemented !
    }

}
