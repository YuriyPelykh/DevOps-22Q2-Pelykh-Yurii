#!/usr/bin/env bash


#Installation of necessary packets:
yum_install() {
    yum install tcpdump -y
    yum install iptables-services -y
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


#Name resolution config:
resolv_config() {
    cp /etc/resolv.conf{,.bak}
    echo "search rocca.local
nameserver 172.16.24.62" > /etc/resolv.conf
}


#Network interfaces configuration:
interfaces_config() {

    touch /etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'TYPE="Ethernet"
    BOOTPROTO="dhcp"
    DEFROUTE="yes"
    IPV4_FAILURE_FATAL="no"
    NAME="eth1"
    DEVICE="eth1"
    PEERDNS="no"
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
    echo 'PEERDNS="no"' >> /etc/sysconfig/network-scripts/ifcfg-eth0

    systemctl restart NetworkManager.service
}

#Firewall config:
firewall_config() {
    systemctl stop firewalld
    systemctl disable firewalld
    systemctl enable iptables

    MAN=eth0
    WAN=eth1
    LAN=eth2
    LAN_IP_RANGE=172.16.24.0/24

    #Cleaning all chains and removing rules:
    iptables -F
    iptables -F -t nat
    iptables -F -t mangle
    iptables -X
    iptables -t nat -X
    iptables -t mangle -X

    #Deny all, what is not allowed:
    iptables -P INPUT DROP
    iptables -P OUTPUT DROP
    iptables -P FORWARD DROP

    #Allow localhost and local network:
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    iptables -A INPUT -i $LAN -j ACCEPT
    iptables -A OUTPUT -o $LAN -j ACCEPT
    #iptables -A INPUT -i $MAN -j ACCEPT
    #iptables -A OUTPUT -o $MAN -j ACCEPT

    # Allow pings:
    iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

    #Open access to the Internet for router:
    iptables -A OUTPUT -o $WAN -j ACCEPT

    #Allow already established connections:
    iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A FORWARD -p all -m state --state ESTABLISHED,RELATED -j ACCEPT

    #Drop unknown packets:
    iptables -A INPUT -m state --state INVALID -j DROP
    iptables -A FORWARD -m state --state INVALID -j DROP

    #Drop zero-packets:
    iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

    #Closing from syn-flood attacks:
    iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
    iptables -A OUTPUT -p tcp ! --syn -m state --state NEW -j DROP

    #Block access from separate IP's:
    #iptables -A INPUT -s 84.122.21.197 -j REJECT

    #Forward port into local network:
    iptables -t nat -A PREROUTING -p tcp --dport 80 -i $WAN -j DNAT --to 172.16.24.254:80
    iptables -A FORWARD -i $WAN -p tcp -m tcp --dport 80 -j ACCEPT

    #Allow access from local net to outside:
    iptables -A FORWARD -i $LAN -o $WAN -j ACCEPT
    #Close access from outside to LAN:
    iptables -A FORWARD -i $WAN -o $LAN -j REJECT

    #NAT enable:
    iptables -t nat -A POSTROUTING -o $WAN -s $LAN_IP_RANGE -j MASQUERADE

    #Open access to SSH:
    iptables -A INPUT -i $WAN -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -i $MAN -p tcp --dport 22 -j ACCEPT

    #Open access to Web-server:
    iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT

    #Open access to DNS-server:
    iptables -A INPUT -i $WAN -p udp --dport 53 -j ACCEPT

    #Save rules:
    /sbin/iptables-save  > /etc/sysconfig/iptables
}


#Routing configuration:
routing_config() {
    ip route del default via 10.0.2.2

    touch /etc/sysconfig/network-scripts/route-eth2
    echo '172.16.24.96/29 via 172.16.24.61
172.16.24.64/27 via 172.16.24.60
172.16.24.248/29 via 172.16.24.59' > /etc/sysconfig/network-scripts/route-eth2
}


yum_install
ip4_forwarding_enable
resolv_config
interfaces_config
firewall_config
routing_config

exit 0


