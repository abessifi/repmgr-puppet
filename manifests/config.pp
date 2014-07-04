class repmgr::config (

    $cluster_name = undef,
    $node_id = undef,
    $node_name = undef,
    $conninfo_host = undef,
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
        ensure => present,
    }
}
