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
    
){

    case $role {

        'master' : {

            if $cluster == undef {
                fail("Cluster name not specified !")
            }
            
            # Continue with other tests

            class { 'repmgr::install':
                node_role         => $role,
                pg_cluster_subnet => $subnet,
            }
            
            class { 'repmgr::config':
                cluster_name  => $cluster,
                node_id       => $id,
                node_name     => $name,
                conninfo_host => $name,
            }
        }
        default : { fail("Invalid value given for role : $role. Must be one of master|slave|witness")  }
    }

}
