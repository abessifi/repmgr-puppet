class repmgr::install{

    File['repmgr-package'] -> Package['repmgr-auto']

    file {'repmgr-package':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        path    => '/var/cache/apt/archives/postgresql-repmgr-9.0_1.0.0.deb',
        source  => 'puppet:///modules/repmgr/postgresql-repmgr-9.0_1.0.0.deb',
    }

    package {'repmgr-auto':
        provider => dpkg,
        ensure => present,
        source => '/var/cache/apt/archives/postgresql-repmgr-9.0_1.0.0.deb',
    } 
}
