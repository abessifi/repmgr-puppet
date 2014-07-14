# == Define: Repmgr
#
# A defined type for managing streaming replication (SR) in postgresql cluster.
#
# Features:
#  * Deploy postgresql cluster
#  * Configure SR on master node (with repmgr)
#  * Configure SR on slave node(s) (with repmgr)
#  * Configure witness node for cluster monitoring (needed for when master failover)
#
# == Parameters
#
# [*ensure*]
#   The state at which to maintain the node.
#   Can be one of "present" or "absent".
#   Present will install and configure repmgr according to "role" value (master or slave).
#   Absent, not yet implemented, will simply purge repmgr installation (config files are included).
#   Default to "present".
#
# [*role*]
#   Is the type of the node (master | slave | witness).
#   PS : Witness config is not yet supported !
#   Default to undef.
#
# [*name*]
#   The short name (or the FQDN) of the node. E.g : node1 | node1.foo.bar
#   Default to undef
#
# [*id*]
#   Is an identifier for every node. It is a number.
#   Default to undef.
#
# [*force*]
#   If true, force potentially dangerous operations to happen.
#   Using this option with :
#      master => force bringing the former master up as a standby
#      slave  => forced clone, which overwrites existing data rather than assuming
#                it starts with an empty database directory tree
#   Default to false.
#
# [*master*]
#   The short name (or the FQDN) of the master node that the slave will follow.
#
# [*cluster*]
#   The name of the cluster within you deploy postgresql nodes.
#   This parameter must be identical for all nodes in the same cluster.
#   Default to undef.
#
# [*subnet*]
#   The IP address of the subnet the postgres nodes are connected to (e.g '192.168.1.0/24').
#   The subnet value is used to set postgresql security access rules (pg_hba.conf).
#   Default to undef.
#
# [*ssh_key*]
#   The postgres user SSH public key.
#   Default to undef.
#
# == Requires:
#    puppet-account >> https://github.com/vaytess/puppet-account
#
# == Examples
#
#   Postgresql Master Config
#
#   repmgr {'pg_master':
#       ensure     => present,
#       role       => master,
#       name       => 'node1',
#       id         => 1,
#       cluster    => 'pg_cluster_name',
#       subnet     => '192.168.1.0/24',
#       ssh_key    => 'AAAAB3Nza....M366wq5',
#   }
#
#   Postgresql Slave Config
#
#   repmgr {'pg_slave':
#       ensure     => present,
#       role       => slave,
#       name       => 'node2',
#       id         => 2,
#       master     => 'node1',
#       force      => true,
#       cluster    => 'pg_cluster_name',
#       subnet     => '192.168.1.0/24',
#       ssh_key    => 'AAAAB3Nza....M366wq5',
#   }
#
# == Authors
#
# Ahmed Bessifi <ahmed.bessifi@gmail.com>
#
# == Licence
#
# GNU GPLv2 - Copyright (C) 2014 Ahmed Bessifi
#

define repmgr(
    $ensure = 'present',
    $role = undef,
    $name = $title,
    $id = undef,
    $master = undef,
    $cluster = undef,
    $subnet = undef,
    $ssh_key = undef,
    $force = false, 
){

    # Some basic tests
    if $cluster == undef {
        fail("Cluster name is required !")
    }
    if $name == undef {
        fail("Node name is required !")
    }
    if $id == undef {
        fail("Node id is required !")
    }
    if $subnet == undef {
        fail("Cluster subnet IP address is not correct !")
    }
    if $ssh_key == undef {
        fail("Postgres public key is required to setup access between nodes !")
    }

    # Set a default $PATH for all execs
    Exec { path => ['/bin', '/usr/bin', '/usr/lib/postgresql/9.1/bin'] }

    # Setting up repmgr regarding node's role
    case $role {

        'master' : {
            # Do something special if master
        }

        'slave' : {
            if  $master == undef {
                fail("Master node name required !")
            }
        }
        'witness' : {
            # Do something special if witness
        }
        default : { fail("Invalid value given for role : $role. Must be one of master|slave|witness")  }
    }

    class { 'repmgr::install':
        node_role         => $role,
        pg_cluster_subnet => $subnet,
        repmgr_ssh_key    => $ssh_key,
    } -> 
    class { 'repmgr::config':
        node_role      => $role,
        cluster_name   => $cluster,
        node_id        => $id,
        node_name      => $name,
        conninfo_host  => $name,
        master_node    => $master,
        force_action   => $force,
    }

}
