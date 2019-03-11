
#!/usr/bin/env bash
# File: Ansible

set -x

# Install Postgresql on the slave Database
function install_postgres {
  sudo apt-get update -y

  sudo apt-get install postgresql postgresql-contrib -y
  # sudo apt-get update 
  # sudo apt-get install postgresql-9.5 postgresql-contrib-9.5 -y
}


# configure the postgres server to to be a slave DB server
function configure_postgresdb {
  sudo ls -ahl
  sudo pwd
  printf "stop postgres in order to configure the slave DB  \n"
  sudo sed -i "s/#listen_address.*/listen_addresses = '*' /" /etc/postgresql/9.5/main/postgresql.conf
  sudo systemctl stop postgresql
  # rename the main dir so the pg_basebackup command can copy the directory from the Master server to this slave server
  sudo mv /var/lib/postgresql/9.5/main /var/lib/postgresql/9.5/main_old
  
  sudo -u postgres pg_basebackup -h 63.35.173.124 -D /var/lib/postgresql/9.5/main -U replicationuser -v --xlog-method=stream

  printf "copy from the host to the remote. \n"
  sudo cp -v /tmp/db_config/recovery.conf /var/lib/postgresql/9.5/main/recovery.conf

  printf "restart postgres \n"
  sudo systemctl start postgresql
}

function main {
  install_postgres
  configure_postgresdb
}

main
