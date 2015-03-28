# encoding: utf-8

require 'spec_helper'

describe package('postgreql') do
  it { should be_installed }
end

describe service('postgresql') do
  it { should be_enabled }
  it { should be_running }
end

describe port('5432') do
  it { should be_listening }
end

describe user('postgres') do
  it { should exist }
end

describe file('/etc/postgresql/9.1/main/postgresql.conf') do
  it { should be_file }
end

# hba_config_file = "#{config_path}/pg_hba.conf"
# postgres_config_file = "#{config_path}/postgresql.conf"
# psql_command = "sudo -u postgres -i PGPASSWORD='#{ENV['PGPASSWORD']}' psql"


