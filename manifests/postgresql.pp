class repmgr::postgresql inherits repmgr::params {

    $pg_ctl = '/usr/lib/postgresql/9.1/bin/pg_ctl'
    $pg_logfile = '/var/log/postgresql/postgresql-9.1-main.log'
    $pg_data = '/var/lib/postgresql/9.1/main'
    $pg_configdir = '/etc/postgresql/9.1/main'

    Package['postgresql'] -> Account['postgres'] -> Service['postgresql']
    
    # Install Postgresql packages
    package {'postgresql':
        name   => $repmgr::params::postgresql,
        ensure => present,
    }

    package {'postgresql_contrib':
        name   => $repmgr::params::postgresql_contrib,
        ensure => present,
    }

    package {'postgresql_server_dev':
        name   => $repmgr::params::postgresql_server_dev,
        ensure => present,
    }

    account {'postgres':
        ensure   => present,
        home_dir => '/var/lib/postgresql',
    }

    file {'postgresql-master-config':
        path   => "$pg_configdir/postgresql.conf.master",
        source => 'puppet:///modules/repmgr/postgresql.conf.master',
        ensure => present,
        owner  => postgres,
        group  => postgres,
        mode   => 0644,
    }

    file {'postgresql-slave-config':
        path   => "$pg_configdir/postgresql.conf.slave",
        source => 'puppet:///modules/repmgr/postgresql.conf.slave',
        ensure => present,
        owner  => postgres,
        group  => postgres,
        mode   => 0644,
    }

    file {'postgresql-hba-config':
        path    => "$pg_configdir/pg_hba.conf",
        ensure  => present,
        owner   => postgres,
        group   => postgres,
        mode    => '0640',
        content => template('repmgr/pg_hba.conf.erb'),
        notify  => Service['postgresql-reload'],
    }
    service {'postgresql':
        ensure  => running,
        status  => "sudo -u postgres $pg_ctl -D $pg_data status",
        start   => "sudo -u postgres $pg_ctl -D $pg_data start -o '-c config_file=$pg_configdir/postgresql.conf -l $pg_logfile",
        # The real Debian way is to use pg_ctlcluster like so :
        # sudo -u postgres pg_ctlcluster 9.3 main start 
        stop    => "sudo -u postgres $pg_ctl -D $pg_data stop -l $pg_logfile",
        restart => "sudo -u postgres $pg_ctl -D $pg_data restart -l $pg_logfile",
    }

    service {'postgresql-reload':
        status  => "sudo -u postgres $pg_ctl -D $pg_data status",
        restart => "sudo -u postgres $pg_ctl -D $pg_data reload",
    }
}
