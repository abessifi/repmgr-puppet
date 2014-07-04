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
    $loglevel = 'debug'
    $monitor_interval = 5

    $pg_contribdir = '/usr/share/postgresql/9.1/contrib'

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
        path      => '/etc/repmgr/repmgr.conf',
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
    Exec['create_repmgr_db_user'] -> Exec['create_repmgr_db'] -> Exec['insert_repmgr_funcs']

    if $node_role == 'master' {
        exec {'create_repmgr_db_user':
            path    => ['/bin/','/usr/bin'],
            command => 'createuser -s repmgr',
            user    => 'postgres',
            #create user if not exist
            #onlyif  => [      
            # 'sudo -u postgres -- [ `psql template1 -c "\du" | grep -c postgres` -eq "0" ] && false || true'
            #],
        }
        exec{'create_repmgr_db':
            path    => ['/bin', '/usr/bin'],
            command => 'createdb -O repmgr repmgr',
            user    => 'postgres',
            #create db if not exist
            #onlyif =>  [
            # 'sudo -u postgres -- psql -l | grep repmgr'
            #],
        }
        exec {'insert_repmgr_funcs':
            path    => ['/usr/bin'],
            command => "psql -f $pg_contribdir/repmgr_funcs.sql repmgr",
            user    => 'postgres',
        }
    }
    elsif $node_role in ['slave', 'witness'] {
        ## Not yet implemented !
    }

}
