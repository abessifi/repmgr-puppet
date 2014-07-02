class repmgr::postgresql {

    $pg_ctl = '/usr/lib/postgresql/9.1/bin/pg_ctl'
    $pg_logfile = '/var/log/postgresql/postgresql-9.1-main.log'
    $pg_data = '/var/lib/postgresql/9.1/main'
    $pg_configdir = '/etc/postgresql/9.1/main'

    service {'postgresql':
        ensure  => running,
        status  => "sudo -u postgres $pg_ctl -D $pg_data status",
        start   => "sudo -u postgres $pg_ctl -D $pg_data start -l $pg_logfile",
        stop    => "sudo -u postgres $pg_ctl -D $pg_data stop -l $pg_logfile",
    }

    service {'postgresql-reload':
        status  => "sudo -u postgres $pg_ctl -D $pg_data status",
        restart => "sudo -u postgres $pg_ctl -D $pg_data reload",
    }

    file {"$pg_configdir/postgresql.conf.master":
        source => 'puppet:///modules/repmgr/postgresql.conf.master',
        ensure => present,
        owner  => postgres,
        group  => postgres,
        mode   => 0644,
    }

    file {"$pg_configdir/postgresql.conf.slave":
        source => 'puppet:///modules/repmgr/postgresql.conf.slave',
        ensure => present,
        owner  => postgres,
        group  => postgres,
        mode   => 0644,
    }

    file {"$pg_configdir/pg_hba.conf":
        ensure  => present,
        owner   => postgres,
        group   => postgres,
        mode    => '0640',
        content => template('repmgr/pg_hba.conf.erb'),
        notify  => Service['postgresql-reload'],
    }
}
