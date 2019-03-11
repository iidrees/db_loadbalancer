#!/usr/bin/env bash
# File: Ansible

set -x

# Install Postgres 
function install_postgres {
  sudo apt-get update -y

  sudo apt-get install postgresql postgresql-contrib -y
}

# configure the postgres server to to be a master DB server
function configure_postgresdb {
  sudo ls -ahl
  sudo pwd

  printf "make an archive directory where data to be replicated to slaves would be stored  \n"
  sudo mkdir -p /var/lib/postgresql/9.5/main/archivedir
  printf "Create the Postgres replica user \n"
  sudo -u postgres createuser -U postgres replicauser -c 5 --replication
  printf "remove the default postgres configuration file \n"
  sudo rm -v /etc/postgresql/9.5/main/postgresql.conf
  sudo rm -v /etc/postgresql/9.5/main/pg_hba.conf

  printf "Replace the removed config files with yours \n"
  sudo cp -v  /tmp/db_config/postgresql.conf /etc/postgresql/9.5/main/postgresql.conf
  sudo cp -v /tmp/db_config/pg_hba.conf /etc/postgresql/9.5/main/pg_hba.conf
  sudo systemctl restart postgresql
  printf "postgres restarted \n"
}

function main {
  install_postgres
  configure_postgresdb
}

main
