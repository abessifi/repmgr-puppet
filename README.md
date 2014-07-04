repmgr-puppet
=============

A puppet module for repmgr to handle Postgres 9.1 streaming replication and orchestration for failing back and forth.

Requirements
------------
This puppet module works with PostgreSQL versions 9.0 and superior.

repmgr-puppet is currently using [puppet-account](https://github.com/vaytess/puppet-account) module to create and manage repmgr user.

Installation Outline
--------------------
1- Install this module in your specific puppet environment.
2- Create repmgr ssh keypair on the master node and transfer it (typically the private key) to other servers :
    $ ssh-keygen -t rsa
3- ...
