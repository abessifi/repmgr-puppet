class repmgr::install (

    $node_role = undef,
    $pg_cluster_subnet = undef,
){
  
    # repmgr depends on some postgresql packages
    include repmgr::postgresql

    Account['postgres'] -> Exec['check_ssh_priv_key'] -> File['pg_ssh_priv_key']
    
    # Assert postgres user exists
    account {'postgres':
        ensure => present,
        home_dir   => "$repmgr::params::pg_home_dir",
        ssh_keys         => {
                'repmgr_key' => {
                    type     => 'ssh-rsa',
                    key      => $repmgr_ssh_key,
                }
        },
    }

    # NOTE : This is a quick way to check if id_rsa private key exists.
    # This exec may be improved (puppetized using fail() function) to be more verbose 
    # and assert that puppet fails when condition is not satisfied (id_rsa not found)
    exec {'check_ssh_priv_key':
        command   => "echo 'Postgres private key doesn\'t exist. Make sure $repmgr::params::pg_home_dir/.ssh/id_rsa exist and then perform puppet again'",
        onlyif    => "[ ! -f $repmgr::params::pg_home_dir/.ssh/id_rsa ]",
        logoutput => true,
        returns   => 1,
    }

    file {'pg_ssh_priv_key':
        path   => "$repmgr::params::pg_home_dir/.ssh/id_rsa",
        ensure => present,
        owner  => postgres,
        group  => postgres,
        mode   => 600,
    }

    file {'pg_ssh_config':
        path  => "$repmgr::params::pg_home_dir/.ssh/config",
        owner => postgres,
        group => postgres,
        mode  => 644,
        content => 'StrictHostKeyChecking no',
    }


    # Apply the correct postgresql config file (master|slave)
    exec {'set_postgres_config':
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
