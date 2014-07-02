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

    $cluster = $title,
    $cluster_subnet = undef,
    $master = undef,
    $slave = undef,
    $witness = undef,
    $name = undef,
    $ensure = present,
    
    ){

    unless $cluster {
       
        fail("Cluster name not specified !")
    }

    if $master == true {
    
        $pg_cluster_subnet = '192.168.1.0/24'

        include repmgr::install
        include repmgr::config
    }
    else {
        fail("Master node not specified !")
    }

}
/*
class repmgr {

    $pg_cluster_subnet = '192.168.1.0/24'

    include repmgr::install
    include repmgr::config
}
*/
