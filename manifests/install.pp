class repmgr::install (

    $node_role = undef,
    $pg_cluster_subnet = undef,
){
  
    # repmgr depends on some postgresql packages
    include repmgr::postgresql

    # Apply the correct postgresql config file (master|slave)
    exec {'set_postgres_config':
        path    => ['/bin', '/usr/bin'],
        command => "cp -p ${repmgr::params::pg_config_file}.${node_role} $repmgr::params::pg_config_file",
        onlyif  => "[ `diff $repmgr::params::pg_config_file ${repmgr::params::pg_config_file}.${node_role} | wc -l` -ne 0 ]",
        notify  => Service['postgresql'],
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
