class repmgr::postgresql inherits repmgr::params {

    Package['postgresql'] -> Service['postgresql']
    # Install Postgresql packages
    package {'postgresql':
        name   => $repmgr::params::postgresql,
        ensure => present,
        before => Package['postgresql_contrib'],
    }

    package {'postgresql_contrib':
        name   => $repmgr::params::postgresql_contrib,
        ensure => present,
        before => Package['postgresql_server_dev'],
    }

    package {'postgresql_server_dev':
        name   => $repmgr::params::postgresql_server_dev,
        ensure => present,
    }

    service {'postgresql':
        ensure  => running,
        status  => "sudo -u postgres $repmgr::params::pg_ctl -D $repmgr::params::pg_data status",
        # Wait 10s to get postgresql reachable
        start   => "sudo -u postgres $repmgr::params::pg_ctl -D $repmgr::params::pg_data start -o '-c config_file=$repmgr::params::pg_config_file' -l $repmgr::params::pg_logfile && sleep 10",
        # The real Debian way is to use pg_ctlcluster like so :
        # sudo -u postgres pg_ctlcluster 9.1 main start 
        stop    => "sudo -u postgres $repmgr::params::pg_ctl -D $repmgr::params::pg_data stop -m fast -l $repmgr::params::pg_logfile",
        restart => "sudo -u postgres $repmgr::params::pg_ctl -D $repmgr::params::pg_data restart -m fast -l $repmgr::params::pg_logfile && sleep 10",
    }

    service {'postgresql-reload':
        status  => "sudo -u postgres $repmgr::params::pg_ctl -D $repmgr::params::pg_data status",
        restart => "sudo -u postgres $repmgr::params::pg_ctl -D $repmgr::params::pg_data reload",
    }
}
