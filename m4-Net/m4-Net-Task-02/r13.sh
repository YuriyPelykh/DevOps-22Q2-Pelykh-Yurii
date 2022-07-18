#!/usr/bin/env bash


#Packages installation with yum:
yum_install() {
    yum makecache --refresh
    yum install dhcp-relay -y
    yum install tcpdump -y
#    yum install dhclient -y
}


#IPv4 forwarding enable:
ip4_forwarding_enable() {
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
}


#Function changes value for specified parameter, uncomment it in config file or adds such if it is absent:
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
      BOOTPROTO="static"
      DEFROUTE="no"
      IPV4_FAILURE_FATAL="no"
      NAME="eth2"
      DEVICE="eth2"
      IPADDR="172.16.24.97"
      DNS1="172.16.24.62"
      PREFIX=29
      GATEWAY=172.16.24.1
      ONBOOT="yes"' > /etc/sysconfig/network-scripts/ifcfg-eth2

    change-config-file "" "DEFROUTE" "=" "no" "/etc/sysconfig/network-scripts/ifcfg-eth0"
    echo 'PEERDNS=no' >> /etc/sysconfig/network-scripts/ifcfg-eth0

    #systemctl restart NetworkManager.service
}


#Routing configuration:
routing_config() {
    ip route del default via 10.0.2.2
    touch /etc/sysconfig/network-scripts/route-eth1
    echo "172.16.24.64/27 via 172.16.24.60
172.16.24.248/29 via 172.16.24.59" > /etc/sysconfig/network-scripts/route-eth1

    systemctl restart NetworkManager.service
}


#DHCP-relay configuration:
dhcrelay_config() {
    sleep 40
    dhcrelay -m append -c 4 -i eth1 -i eth2 172.16.24.62
}


#Modificate rc.local:
mod_rclocal() {
    echo "dhcrelay -m append -c 4 -i eth1 -i eth2 172.16.24.62" >> /etc/rc.d/rc.local
}

#Firewall disable:
firewall_config() {
    systemctl stop firewalld
    systemctl disable firewalld
}


yum_install
ip4_forwarding_enable
interfaces_config
routing_config
dhcrelay_config
firewall_config
mod_rclocal

exit 0


