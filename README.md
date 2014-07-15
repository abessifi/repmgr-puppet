# Puppet repmgr Module

A puppet module for [repmgr](http://www.repmgr.org) to handle Postgres 9.1 SR (Streaming Replication) and orchestration for failing back and forth.

Currently supports:

  * Deploy PostgreSQL cluster.
  * Configure SR on master node (with repmgr).
  * Configure SR on slave node(s) (with repmgr).

Notes/Drawbacks:

  * It is tested only on Debian 7 "Wheezy" with pre-built package "postgresql-repmgr-9.0_1.0.0.deb".
  * Does not take off slave(s) from cluster. "ensure => absent" not supported.
  * Does not support automatic failover.
  * If it is not a fresh install, existing data will be removed during the first sync with master. Backup your databases from slave(s).
  * Puppet agent is launched for one time. Once your cluster is configured, comment/remove the repmgr configurations from puppet server. Otherwise, if a slave become a master, puppet (in next launch) will turn it a slave again.

## Documentation

A brief usage summary with examples follows.
For full documentation of all parameters, see the inline puppet docs:

    $ puppet doc repmgr/manifests/init.pp

# Installation Outline

## Summary

For convenience, we assume that we have a PostgreSQL cluster with three nodes:
master => node1 (192.168.1.10)
slaves => node2 (192.168.1.20), node3 (192.168.1.30)

To install and use repmgr and repmgrd, Puppet proceeds as follow:

1. Install PostgreSQL and repmgr in all the servers involved.
2. Configure the PostreSQL Master.
3. Configure repmgr and register the Master node.
4. Configure repmgr in the Standby node(s).
6. Clone the Master to the Standby node(s).
7. Register the Standby node(s).
8. Start the repmgrd daemon in the Standby node(s).

**Note:** 
* It is not recommanded to use name defining status of a server like «masterserver», this is a name leading to confusion once a failover take place and the Master is now on the «standbyserver».
* 2 PostgreSQL servers are involved in the replication. Automatic fail-over need to vote to decide what server it should promote, thus an odd number (node id) is required and a witness-repmgrd is installed in a third server where it uses a PostgreSQL cluster to communicate with other repmgrd daemons. This feature is not yet supported but could be handled manually with repmgr commands.

## Requirements

This Puppet module works with PostgreSQL version 9.0 and superior.

repmgr-puppet is currently using [puppet-account](https://github.com/vaytess/puppet-account) module to create and manage postgres user.

## Usage

If you are not using a DNS server, assert that in each host, you have a domain name resolution entry in /etc/hosts for each node. E.g :

    192.168.1.10   node1.local node1
    192.168.1.20   node2.local node2
    192.168.1.30   node3.local node3

Then, make sure that each node can reach other nodes through its short name (or fqdn) by ping or SSH.

Now, to deploy a PostgreSQL cluster and use repmgr automatically, follow these steps:

### In all nodes:
As root, create postgres home and ssh keys directories :

    # mkdir -p /var/lib/postgresql/.ssh

### In master node:

If a PostgreSQL server in node1 exists already :

  * Backup your databases :

    (node1)$ pg_dump -U {username} -c {db_name} -f /somewhere/{db_name}_backup.sql

  * Make sure that the server is down :

    (node1)$ /etc/init.d/postgresql stop

Create postgres ssh private key into "/var/lib/postgresql/.ssh/id_rsa" without passphrase (empty passphrase):

    (node1)# ssh-keygen -t rsa

Make sure the keypair {id_rsa, id_rsa.pub} exists in "/var/lib/postgresql/.ssh/". Remember the ssh public key "id_rsa.pub", we'll need it later.

Copy the resulting private key to /var/lib/postgresql/.ssh on the other slave/standby system(s):

    (node1)# cd /var/lib/postgresql/.ssh
    (node1)# scp id_rsa root@{each_slave}:/var/lib/postgresql/.ssh

Setup repmgr master configuration in your puppetmaster (nodes.pp):

    node 'node1.local' {
        repmgr {'node1':
            ensure  => present,
            role    => master,
            name    => 'node1',
            id      => 1,
            cluster => 'foobar',
            subnet  => '192.168.1.0/24',
            ssh_key => 'AAAAB3N....BLABLA',
        }
    }

Start puppet in node1 in order to install/transform PostgreSQL to master server. E.g:

    # puppet agent --server=puppetmaster.local --test --environment=development

Puppet should finish correctly. Then check that the master is now registred by repmgr:

    (node1)# repmgr -f /etc/repmgr/repmgr.conf cluster show

As a result, you should see this output:

    [INFO] repmgr connecting to database
    Role      | Connection String 
    * master  | host=node1 user=repmgr dbname=repmgr

Check your existing BDs (Restore them from backup if they are corrupted).

Your PostgreSQL Master is now ready ;)

### In standby node(s):

Make sure the PostgreSQL Master is running. Otherwise Standby creation will fail.

If the standby node is running a PostgreSQL server (so this is not a fresh install), make sure you backup your databases.

Setup repmgr master configuration in your puppetmaster (nodes.pp). E.g for node2:

    node 'node2.local'{
        repmgr {'node2':
            ensure  => present,
            role    => slave,
            name    => 'node2',
            id      => 2,
            master  => 'node1',
            force   => true,
            cluster => 'foobar',
            subnet  => '192.168.1.0/24',
            ssh_key => 'AAAAB3N....BLABLA',
        }
    }

Start puppet in node2 in order to install/transform PostgreSQL to Standby server. E.g:

    # puppet agent --server=puppetmaster.local --test --environment=development

Repeat the same steps in the node3.

Check that Standby nodes are correctly registred:

    (node1)# repmgr -f /etc/repmgr/repmgr.conf cluster show

You should see this output:

    [INFO] repmgr connecting to database
    Role      | Connection String 
    * master  | host=node1 user=repmgr dbname=repmgr
    standby   | host=node2 user=repmgr dbname=repmgr
    standby   | host=node3 user=repmgr dbname=repmgr

Now, test the replication by creating for example a database in Master side. This database should appear directly in Standby nodes.

**Note:**
PostgreSQL machines have to be known by puppetmaster, so they could fetch and apply their configurations.
For more informations about how to manage nodes role with repmgr commands, see [here](https://github.com/2ndQuadrant/repmgr).

## Troubleshooting

If cloning fails:
* Standby server must be absolutely down. Assert that no postgres process is blocked/running. Otherwise force killing them manually (killall postgres).
* Check that Master node is reachable via SSH.
* Use force option (force => true) if needed.

## Contribution & feedbacks

Please use the github issues functionality to report any bugs or requests for new features.

Feel free to fork and submit pull requests (or use git's own functionality to mail me patches) for potential contributions ;)

## TODO

* Test with other Debian versions and with the default repmgr package on the APT repository.
* Suppport for removing slave(s).
* Reconfigure nodes after automatic failover when it detects the failure of the Master.
* Support PGBouncer for connection pooling (master side).
* Submit module to PuppetForge.
