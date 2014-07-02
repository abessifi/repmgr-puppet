class repmgr::config {

    Account['repmgr'] -> Repmgr::Config_params['repmgr_config_file']

    # Create repmgr config dir
    file {'/etc/repmgr':
        ensure => 'directory',
        owner  => root,
        group  => root,
        mode   => '0755',
    }

    # Generate repmgr config file
    repmgr::config_params {'repmgr_config_file':
        cluster_name => 'collections',
        node_id      => 1,
        node_name    => 'node1',
        conninfo_host => 'node1',
        conninfo_user => 'repmgr',
        conninfo_dbname =>'repmgr',
    }

    # Create repmgr user
    account {'repmgr':
        ensure => present,
    }
}
