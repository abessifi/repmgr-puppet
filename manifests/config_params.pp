define repmgr::config_params(

    $cluster_name = 'test',
    $node_id = 1,
    $node_name = 'node1',
    $conninfo_host = 'node1',
    $conninfo_user = 'repmgr',
    $conninfo_dbname = 'repmgr',
    $pg_bindir = '/usr/lib/postgresql/9.1/bin',
    $master_response_timeout = 20,
    $reconnect_attempts = 4,
    $reconnect_interval = 10,
    $failover = 'automatic',
    $promote_command = 'repmgr -f /etc/repmgr/repmgr.conf standby promote',
    $follow_command  = '/var/lib/postgresql/follow_command.sh',
    $loglevel = 'debug'){
    
    file {'repmgr_config_file':
        ensure    => present,
        owner     => repmgr,
        group     => repmgr,
        mode      => '0644',
        # require => Package['repmgr-auto'],
        content   => template('repmgr/repmgr.conf.erb'),
        path      => '/etc/repmgr/repmgr.conf',
    }
}
