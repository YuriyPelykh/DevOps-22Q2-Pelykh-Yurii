#!/usr/bin/env bash

#IPv4 forwarding enable:
ip4_forwarding_enable() {
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
}

#Network interfaces configuration:
interfaces_config() {
    touch /etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'TYPE="Ethernet"\nBOOTPROTO="dhcp"\nDEFROUTE="yes"\nIPV4_FAILURE_FATAL="no"NAME="eth1"\nDEVICE="eth1"\nONBOOT="yes"' > /etc/sysconfig/network-scripts/ifcfg-eth1
    #ifdown eth1
    #ifup eth1

    touch /etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'TYPE="Ethernet"\nBOOTPROTO="dhcp"\nDEFROUTE="yes"\nIPV4_FAILURE_FATAL="no"NAME="eth2"\nDEVICE="eth2"\nONBOOT="yes"' > /etc/sysconfig/network-scripts/ifcfg-eth2
    #ifdown eth2
    #ifup eth2
}

#Firewall config:
firewall_config() {
    export MAN=eth0
    export WAN=eth1
    #export WAN_IP=85.31.203.127
    export LAN=eth2
    export LAN_IP_RANGE=172.16.24.0/24

    #Cleaning all chains and removing rules:
    iptables -F
    iptables -F -t nat
    iptables -F -t mangle
    iptables -X
    iptables -t nat -X
    iptables -t mangle -X

    # Запрещаем все, что не разрешено:
    iptables -P INPUT DROP
    iptables -P OUTPUT DROP
    iptables -P FORWARD DROP

    # Разрешаем localhost и локалку:
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    iptables -A INPUT -i $LAN -j ACCEPT
    iptables -A OUTPUT -o $LAN -j ACCEPT
    #iptables -A INPUT -i $MAN -j ACCEPT
    #iptables -A OUTPUT -o $MAN -j ACCEPT

    # Рзрешаем пинги
    iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

    #Open access to the Internet for router
    iptables -A OUTPUT -o $WAN -j ACCEPT

    #Разрешаем установленные подключения:
    iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A FORWARD -p all -m state --state ESTABLISHED,RELATED -j ACCEPT

    # Отбрасываем неопознанные пакеты
    iptables -A INPUT -m state --state INVALID -j DROP
    iptables -A FORWARD -m state --state INVALID -j DROP

    # Отбрасываем нулевые пакеты
    iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

    # Закрываемся от syn-flood атак
    iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
    iptables -A OUTPUT -p tcp ! --syn -m state --state NEW -j DROP

    # Блокируем доступ с указанных адресов
    #iptables -A INPUT -s 84.122.21.197 -j REJECT

    # Пробрасываем порт в локалку
    #iptables -t nat -A PREROUTING -p tcp --dport 23543 -i ${WAN} -j DNAT --to 10.1.3.50:3389
    #iptables -A FORWARD -i $WAN -d 10.1.3.50 -p tcp -m tcp --dport 3389 -j ACCEPT

    # Разрешаем доступ из локалки наружу
    iptables -A FORWARD -i $LAN -o $WAN -j ACCEPT
    # Закрываем доступ снаружи в локалку
    iptables -A FORWARD -i $WAN -o $LAN -j REJECT

    # Включаем NAT
    iptables -t nat -A POSTROUTING -o $WAN -s $LAN_IP_RANGE -j MASQUERADE

    # открываем доступ к SSH
    iptables -A INPUT -i $WAN -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -i $MAN -p tcp --dport 22 -j ACCEPT

    #Открываем доступ к web серверу
    iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT

    #Открываем доступ к DNS серверу
    iptables -A INPUT -i $WAN -p udp --dport 53 -j ACCEPT

    # Сохраняем правила
    /sbin/iptables-save  > /etc/sysconfig/iptables
}

routing_config() {
    
}

ip4_forwarding_enable
interfaces_config
systemctl restart networking
firewall_config

exit 0


