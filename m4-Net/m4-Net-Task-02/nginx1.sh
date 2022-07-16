#!/usr/bin/env bash


#Installation packages with apt:
apt_install() {
    apt-get update
    apt-get install nginx -y
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
    touch /etc/netplan/02-netcfg.yaml
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
      dhcp4: true
      dhcp6: false" > /etc/netplan/02-netcfg.yaml

    ip link set eth1 up
    netplan apply
}


#Firewall config:
firewall_config() {
#    systemctl stop firewalld
#    systemctl disable firewalld
#    yum install iptables-services -y
#    systemctl enable iptables
#
#    MAN=eth0
#    WAN=eth1
#    #export WAN_IP=85.31.203.127
#    LAN=eth2
#    LAN_IP_RANGE=172.16.24.0/24
#
#    #Cleaning all chains and removing rules:
#    iptables -F
#    iptables -F -t nat
#    iptables -F -t mangle
#    iptables -X
#    iptables -t nat -X
#    iptables -t mangle -X
#
#    # Запрещаем все, что не разрешено:
#    iptables -P INPUT DROP
#    iptables -P OUTPUT DROP
#    iptables -P FORWARD DROP
#
#    # Разрешаем localhost и локалку:
#    iptables -A INPUT -i lo -j ACCEPT
#    iptables -A OUTPUT -o lo -j ACCEPT
#    iptables -A INPUT -i $LAN -j ACCEPT
#    iptables -A OUTPUT -o $LAN -j ACCEPT
#    #iptables -A INPUT -i $MAN -j ACCEPT
#    #iptables -A OUTPUT -o $MAN -j ACCEPT
#
#    # Рзрешаем пинги
#    iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
#    iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
#    iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
#    iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
#
#    #Open access to the Internet for router
#    iptables -A OUTPUT -o $WAN -j ACCEPT
#
#    #Разрешаем установленные подключения:
#    iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
#    iptables -A OUTPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
#    iptables -A FORWARD -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
#
#    # Отбрасываем неопознанные пакеты
#    iptables -A INPUT -m state --state INVALID -j DROP
#    iptables -A FORWARD -m state --state INVALID -j DROP
#
#    # Отбрасываем нулевые пакеты
#    iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
#
#    # Закрываемся от syn-flood атак
#    iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
#    iptables -A OUTPUT -p tcp ! --syn -m state --state NEW -j DROP
#
#    # Блокируем доступ с указанных адресов
#    #iptables -A INPUT -s 84.122.21.197 -j REJECT
#
#    # Пробрасываем порт в локалку
#    #iptables -t nat -A PREROUTING -p tcp --dport 23543 -i ${WAN} -j DNAT --to 10.1.3.50:3389
#    #iptables -A FORWARD -i $WAN -d 10.1.3.50 -p tcp -m tcp --dport 3389 -j ACCEPT
#
#    # Разрешаем доступ из локалки наружу
#    iptables -A FORWARD -i $LAN -o $WAN -j ACCEPT
#    # Закрываем доступ снаружи в локалку
#    iptables -A FORWARD -i $WAN -o $LAN -j REJECT
#
#    # Включаем NAT
#    iptables -t nat -A POSTROUTING -o $WAN -s $LAN_IP_RANGE -j MASQUERADE
#
#    # открываем доступ к SSH
#    iptables -A INPUT -i $WAN -p tcp --dport 22 -j ACCEPT
#    iptables -A INPUT -i $MAN -p tcp --dport 22 -j ACCEPT
#
#    #Открываем доступ к web серверу
#    iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
#    iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
#
#    #Открываем доступ к DNS серверу
#    iptables -A INPUT -i $WAN -p udp --dport 53 -j ACCEPT
#
#    # Сохраняем правила
#    /sbin/iptables-save  > /etc/sysconfig/iptables

    ufw app list
    ufw allow 'Nginx HTTP'
    ufw status
}


nginx_config() {
    systemctl status nginx
    systemctl enable nginx
    mkdir -p /var/www/roccatech.net/html
    chown -R $USER:$USER /var/www/roccatech.net/html
    chmod -R 755 /var/www/roccatech.net

    domain=roccatech.net

    touch /var/www/${domain}/html/index.html
    echo "<html>
    <head>
        <title>Welcome to ${domain}!</title>
    </head>
    <body>
        <h1>Success!  The ${domain} server block is working!</h1>
    </body>
</html>" > /var/www/${domain}/html/index.html

    touch /etc/nginx/sites-available/${domain}
    echo "server {
        listen 80;
        listen [::]:80;

        root /var/www/${domain}/html;
        index index.html index.htm index.nginx-debian.html;

        server_name ${domain} www.${domain};

        location / {
                try_files $uri $uri/ =404;
        }
}" > /etc/nginx/sites-available/${domain}

    ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/

    cp /etc/nginx/nginx.conf{,.bak}
    change-config-file "" "server_names_hash_bucket_size" "" "" "/etc/nginx/nginx.conf"

    nginx -t
    systemctl restart nginx

}


routing_config() {
    ip route del default via 10.0.2.2
    ip route add 172.16.24.96/29 via 172.16.24.61
    ip route add 172.16.24.64/27 via 172.16.24.60
}


apt_install
interfaces_config
nginx_config
firewall_config
routing_config

exit 0
