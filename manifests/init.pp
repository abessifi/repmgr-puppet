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
# [*cluster*]
#   The name of the cluster you deploy postgresql nodes.
#   By default cluster's value is the repmgr resource title.
#   This parameter is required and must have the same value for all nodes in the same cluster.
#
# [*master*]
#  If true, the node will be configured as postgresql master server.
#  The short name or the FQDN of the postgresql master node.
#  This parameter is required (default to false).
#  
#
#
#
#
# == Examples
#
#
#
# == Authors
#
# Ahmed Bessifi <ahmed.bessifi@gmail.com>
#

define repmgr(
    $ensure = 'present',
    $role = undef,
    $name = $title,
    $id = undef,
    $cluster = undef,
    $subnet = undef,
    $repmgr_key = undef, 
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
    if $repmgr_key == undef {
        fail("repmgr public key is required to setup access between nodes !")
    }

    # Setting up repmgr regarding node's role
    case $role {

        'master' : {

            class { 'repmgr::install':
                node_role         => $role,
                pg_cluster_subnet => $subnet,
            }
            
            class { 'repmgr::config':
                cluster_name   => $cluster,
                node_id        => $id,
                node_name      => $name,
                conninfo_host  => $name,
                repmgr_ssh_key => $repmgr_key,
            }
        }
        default : { fail("Invalid value given for role : $role. Must be one of master|slave|witness")  }
    }

}
