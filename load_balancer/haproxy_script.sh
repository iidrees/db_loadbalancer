
#!/usr/bin/env bash
# File: Haproxy

set -x

function install_haproxy {
  sudo apt-get update -y

  sudo apt-get install haproxy -y

  sudo rm -v /etc/haproxy/haproxy.cfg
  sudo cp -v /tmp/load_balancer/haproxy.cfg /etc/haproxy/haproxy.cfg

  printf "Validate haproxy configuration \n"
  sudo haproxy -c -f /etc/haproxy/haproxy.cfg

  printf "Restart the haproxy service \n"
  sudo service haproxy restart
}

function main {
  install_haproxy
}

main

