#!/usr/bin/env bash

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
    touch /etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'TYPE="Ethernet"
    BOOTPROTO="dhcp"
    DEFROUTE="no"
    IPV4_FAILURE_FATAL="no"
    NAME="eth1"
    DEVICE="eth1"
    ONBOOT="yes"' > /etc/sysconfig/network-scripts/ifcfg-eth1

    touch /etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'TYPE="Ethernet"
    BOOTPROTO="dhcp"
    DEFROUTE="no"
    IPV4_FAILURE_FATAL="no"
    NAME="eth2"
    DEVICE="eth2"
    ONBOOT="yes"' > /etc/sysconfig/network-scripts/ifcfg-eth2

    change-config-file "" "DEFROUTE" "=" "no" "/etc/sysconfig/network-scripts/ifcfg-eth0"

    systemctl restart NetworkManager.service
}


routing_config() {
    ip route del default via 10.0.2.2
}

ip4_forwarding_enable
interfaces_config
routing_config

exit 0


