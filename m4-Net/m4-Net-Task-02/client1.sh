#!/usr/bin/env bash

yum_install () {
    yum makecache --refresh
    yum install traceroute -y
#    yum install dhclient -y
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
    touch /etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'TYPE="Ethernet"
    BOOTPROTO="dhcp"
    IPV4_FAILURE_FATAL="no"
    DEFROUTE="yes"
    NAME="eth1"
    DEVICE="eth1"
    ONBOOT="yes"' > /etc/sysconfig/network-scripts/ifcfg-eth1

    cp /etc/sysconfig/network-scripts/ifcfg-eth0{,.bak}
    change-config-file "" "DEFROUTE" "=" "no" "/etc/sysconfig/network-scripts/ifcfg-eth0"
    echo 'PEERDNS=no' >> /etc/sysconfig/network-scripts/ifcfg-eth0

    systemctl restart NetworkManager.service
}


dhclient_config() {
    cp /etc/dhcp/dhclient.conf{,.bak}
    echo 'interface "eth1" {
  send dhcp-client-identifier "net1";
}' > /etc/dhcp/dhclient.conf

    dhclient -r
    dhclient -d
}


routing_config() {
    ip route del default via 10.0.2.2
    ip route add 172.16.24.0/26 via 172.16.24.97
}

yum_install
interfaces_config
#dhclient_config
routing_config

exit 0


