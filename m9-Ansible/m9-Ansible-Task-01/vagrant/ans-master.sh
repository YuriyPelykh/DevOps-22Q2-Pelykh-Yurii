#!/usr/bin/env bash


#Packages installation with apt:
apt_install () {
    apt-get update
    apt-get install python3-pip sshpass -y
    pip3 install ansible
}


#IP interfaces configuration:
interfaces_config() {
#    cp /etc/netplan/01-netcfg.yaml{,.bak}
#    echo "network:
#  version: 2
#  renderer: networkd
#  ethernets:
#    eth0:
#      dhcp4: true
#      dhcp4-overrides:
#        use-dns: false
#        use-routes: false
#      dhcp6: false
#      optional: true" > /etc/netplan/01-netcfg.yaml

    touch /etc/netplan/02-netcfg.yaml
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
      addresses: [192.168.20.1/24]
#      gateway4: 172.16.24.1" > /etc/netplan/02-netcfg.yaml

    ip link set eth1 up
    netplan apply
}

keys_distrib() {
    #Key generation:
    ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y

    #Key distrib:
    #echo "$USERPASS" | sshpass ssh-copy-id -f -i $KEYLOCATION "$USER"@"$TARGETIP"
}


apt_install
interfaces_config

exit 0
