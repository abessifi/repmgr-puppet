class repmgr {

    $pg_cluster_subnet = '192.168.1.0/24'

    include repmgr::install
    include repmgr::config
}
