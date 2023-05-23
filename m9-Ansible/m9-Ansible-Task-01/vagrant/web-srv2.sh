#!/usr/bin/env bash


#Packages installation with apt:
apt_install () {
    apt-get update
}


#IP interfaces configuration:
interfaces_config() {
    touch /etc/netplan/02-netcfg.yaml
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
      addresses: [192.168.20.4/24]
#      gateway4: 172.16.24.1" > /etc/netplan/02-netcfg.yaml

    ip link set eth1 up
    netplan apply
}

#apt_install
interfaces_config

exit 0