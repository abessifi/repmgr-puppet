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
#   This parameter is required.
#
# [*master*]
#  The short name, fqdn or the IP address of the postgresql master node.
#  This parameter is required.
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
    $slaves = [],
    $witness = undef,
    $ensure = present,
    ){

    unless $cluster {
       
        fail("Cluster name not specified !")
    }

    if $master {
    
    }
    else {
        fail("Master node not specified !")
    }

    $pg_cluster_subnet = '192.168.1.0/24'

    include repmgr::install
    include repmgr::config

}
/*
class repmgr {

    $pg_cluster_subnet = '192.168.1.0/24'

    include repmgr::install
    include repmgr::config
}
*/
