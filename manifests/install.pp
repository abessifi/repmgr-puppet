class repmgr::install(

    $node_role = undef,
    $pg_cluster_subnet = undef,
){
      
    # repmgr depends on some postgresql packages
    include repmgr::postgresql

    $pg_configdir = '/etc/postgresql/9.1/main'

    # Apply the correct postgresql config file (master|slave)
    if $node_role == 'master' {
        exec {'set_pg_master_config':
            path    => ['/bin', '/usr/bin'],
            command => "cp -p $pg_configdir/postgresql.conf.master $pg_configdir/postgresql.conf",
            onlyif  => '[ `diff postgresql.conf postgresql.conf.master | wc -l` -ne 0 ]',
            notify  => Service['postgresql'],
        }
    }
    elsif $node_role in ['slave', 'witness'] {
        ## Not yet implemented !
    }

    # repmgr needs rsync also
    package {'rsync':
        ensure => present,
    }

    # Assert that repmgr-auto is uploaded the installed
    File['repmgr-package'] -> Package['repmgr-auto']

    # Upload the repmgr deb package to be installed
    file {'repmgr-package':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        path    => '/var/cache/apt/archives/postgresql-repmgr-9.0_1.0.0.deb',
        source  => 'puppet:///modules/repmgr/postgresql-repmgr-9.0_1.0.0.deb',
    }

    # Install repmgr deb package if not exists
    package {'repmgr-auto':
        provider  => dpkg,
        ensure    => present,
        source    => '/var/cache/apt/archives/postgresql-repmgr-9.0_1.0.0.deb',
        require => [
            Package["rsync"],
            Package["$repmgr::params::postgresql"],
            Package["$repmgr::params::postgresql_contrib"],
            Package["$repmgr::params::postgresql_server_dev"]        
        ]
    }
}
