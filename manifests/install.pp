class repmgr::install inherits repmgr::params {

    File['repmgr-package'] -> Package['repmgr-auto']

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
            Package["$postgresql"],
            Package["$postgresql_contrib"],
            Package["$postgresql_server_dev"]        
        ],
    }

}
