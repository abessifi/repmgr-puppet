class repmgr::config {

    Account['repmgr'] -> Repmgr::Config_params['repmgr_config_file']

    file {'/etc/repmgr':
        ensure => 'directory',
        owner  => root,
        group  => root,
        mode   => '0755',
    }

    repmgr::config_params {'repmgr_config_file':
        cluster_name => 'collections',
        node_id      => 1,
        node_name    => 'node1',
        conninfo_host => 'node1',
        conninfo_user => 'repmgr',
        conninfo_dbname =>'repmgr',
    }

    account {'repmgr':
        ensure => present,
    }
}
