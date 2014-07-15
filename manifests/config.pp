$repmgr_options = '--verbose'

class repmgr::config (

    $node_role = undef,
    $cluster_name = undef,
    $node_id = undef,
    $node_name = undef,
    $conninfo_host = undef,
    $master_node = undef,
    $force_action = false,
){
    $conninfo_user = 'repmgr'
    $conninfo_dbname = 'repmgr'
    $pg_bindir = $repmgr::params::pg_bin_dir 
    $master_response_timeout = 20
    $reconnect_attempts = 4
    $reconnect_interval = 10
    $failover = 'automatic'
    $promote_command = "repmgr -f $repmgr::params::repmgr_conf_file standby promote"
    $follow_command  = "$repmgr::params::pg_home_dir/follow_command.sh"
    $loglevel = 'DEBUG'
    $monitor_interval = 5

    if $force_action {
        $repmgr_options = "${repmgr_options} --force"
    }

    File['repmgr_config_dir'] -> File['repmgr_config_file']

    # Create repmgr config dir
    file {'repmgr_config_dir':
        path   => '/etc/repmgr',
        ensure => 'directory',
        owner  => root,
        group  => root,
        mode   => '0755',
    }

    # Generate repmgr config file
    file {'repmgr_config_file':
        ensure    => present,
        owner     => postgres,
        group     => postgres,
        mode      => '0644',
        content   => template('repmgr/repmgr.conf.erb'),
        path      => $repmgr::params::repmgr_conf_file,
    }

    # Assert that repmgrd log directory exists
    file {'repmgrd_log_dir':
        ensure => directory,
        path   => $repmgr::params::repmgrd_log_dir,
        owner  => postgres,
        group  => postgres,
        mode   => 644,
    }

    if $node_role == 'master' {
        
        Exec['create_repmgr_db_user'] -> Exec['create_repmgr_db'] -> Exec['master_register']
        
        # Create the user and database to manage replication
        exec {'create_repmgr_db_user':
            command  => 'createuser -s repmgr',
            user     => 'postgres',
            onlyif   => '[ `psql template1 -c "\du" | grep -c repmgr` -eq "0" ]',
        }

        exec{'create_repmgr_db':
            command  => "createdb -O repmgr repmgr && psql -f $repmgr::params::pg_contrib_dir/repmgr_funcs.sql repmgr && sleep 5",
            user     => 'postgres',
            onlyif   => '[ `psql -l | grep -c repmgr` -eq "0" ]',
        } 
        # Register master node if it's not and only if repmgr database has been created
        exec {'master_register':
            command => "repmgr -f $repmgr::params::repmgr_conf_file master register",
            user    => 'postgres',
            onlyif  => [
                "psql -l | grep repmgr",
                "[ `repmgr -f $repmgr::params::repmgr_conf_file cluster show | grep -c master` -eq 0 ]"
            ],
        }
    }
    elsif $node_role in ['slave', 'witness'] {

        Exec['stop_repmgrd'] -> Exec['stop_standby'] -> Exec['clean_pg_data'] -> Exec['clone_master'] ~> Service['postgresql'] -> Exec['standby_register'] -> Exec['start_repmgrd']

        # Stop repmgrd if running
        exec {'stop_repmgrd':
            command => 'killall repmgrd',
            onlyif   => "[ `pidof repmgrd` ]",
        }
        # Stop standby node if running
        exec {'stop_standby':
            command => "sudo -u postgres $repmgr::params::pg_ctl -D $repmgr::params::pg_data stop -m fast -l $repmgr::params::pg_logfile",
            onlyif  => "[ `killall -0 postgres 2>&1 | grep -c postgres` -eq 0 ]",
        }

        # Clean postgres data dir before the fist clone (this is done juste once)
        exec {'clean_pg_data':
            command => "rm -r $repmgr::params::pg_data",
            onlyif  => "[ ! -f $repmgr::params::pg_data/recovery.conf ]",
        }
        
        # Clone the master and start standby
        exec {'clone_master':
            command => "sudo -u postgres repmgr -f $repmgr::params::repmgr_conf_file -D $repmgr::params::pg_data -d repmgr -U repmgr -R postgres standby clone $master_node $repmgr_options",
        }

        # Register the standby server if it's not
        exec {'standby_register':
            command   => "sudo -u postgres repmgr -f $repmgr::params::repmgr_conf_file standby register",
            onlyif    => "[ `repmgr -f $repmgr::params::repmgr_conf_file cluster show | grep -c 'standby | host=$node_name'` -eq 0 ]",
        }
        # Start repmgrd daemon
        # NOTE running repmgrd via an init script will be better
        exec {'start_repmgrd':
            command => "sudo -u postgres repmgrd -f $repmgr::params::repmgr_conf_file -d --monitoring-history > ${repmgr::params::repmgrd_log_dir}/repmgrd.log 2>&1",
            onlyif   => "[ `killall -0 repmgrd 2>&1 | grep -c repmgrd` -ne 0 ]",
        }
    }
}
