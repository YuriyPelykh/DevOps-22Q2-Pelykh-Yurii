#!/usr/bin/env bash

apt_install() {
    apt-get update
    debconf-set-selections <<< "isc-dhcp-relay isc-dhcp-relay/servers string 172.16.24.62"
    debconf-set-selections <<< "isc-dhcp-relay isc-dhcp-relay/interfaces string \"eth1 eth2\""
    debconf-set-selections <<< "isc-dhcp-relay isc-dhcp-relay/options string \"-m append -c 3\""
    apt-get install isc-dhcp-relay -y
    apt-get install tcpdump -y
}


#IPv4 forwarding enable:
ip4_forwarding_enable() {
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
}


change-config-file() {
cp $5{,.bak}
while IFS='' read -r a
    do
    if [[ $(echo $a | grep -q $2 ; echo $?) != 0 ]]; then
        echo "${a//$1/$1 $2=$4}"
    else
        if [[ $(expr index "$a" $'\t' > /dev/null; echo $?) == 0  ]]; then
            r=$(echo $a | grep -oP "(# )*$2[ =\t]{1,3}([a-z0-9\"]+)*" | cut -d' ' -f1,2 --output-delimiter=$'\t')
        else
            r=$(echo $a | grep -oP "(# )*$2[ =\t]{1,3}([a-z0-9\"]+)*")
        fi
        echo -e "${a//$r/$2$3\"$4\"}"
    fi
    done < $5 > $5.t
mv $5{.t,}
}


#Network interfaces configuration:
interfaces_config() {
    cp /etc/netplan/01-netcfg.yaml{,.bak}
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
      dhcp4-overrides:
        use-dns: false
        use-routes: false
      dhcp6: false
      optional: true" > /etc/netplan/01-netcfg.yaml

    touch /etc/netplan/02-netcfg.yaml
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
      dhcp4: true
      dhcp6: false" > /etc/netplan/02-netcfg.yaml

    touch /etc/netplan/03-netcfg.yaml
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth2:
      addresses: [172.16.24.249/29]
      gateway4: 172.16.24.1
      nameservers:
        addresses: [172.16.24.62]
        search:
        - rocca.local" > /etc/netplan/03-netcfg.yaml

    ip link set eth1 up
    ip link set eth2 up
    netplan apply
}


firewalld_disable() {
    systemctl stop firewalld
    systemctl disable firewalld
}


routing_config() {
    ip route del default via 10.0.2.2
    ip route add default via 172.16.24.1
}


dhcrelay_config() {
#    change-config-file "" "SERVERS" "=" "172.16.24.62" "/etc/default/isc-dhcp-relay"
#    change-config-file "" "INTERFACES" "=" "\"eth1 eth2\"" "/etc/default/isc-dhcp-relay"
#    change-config-file "" "OPTIONS" "=" "\"-m append -c 3\"" "/etc/default/isc-dhcp-relay"
#    dhcrelay -m append -c 3 -i eth1 -i eth2 172.16.24.62
    systemctl restart isc-dhcp-relay
    systemctl enable isc-dhcp-relay
}


apt_install
ip4_forwarding_enable
interfaces_config
#firewalld_disable
routing_config
dhcrelay_config

exit 0


