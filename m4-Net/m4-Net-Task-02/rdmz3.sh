#!/usr/bin/env bash


#Packages installation with apt:
apt_install() {
    apt-get update
    debconf-set-selections <<< "isc-dhcp-relay isc-dhcp-relay/servers string 172.16.24.62"
    debconf-set-selections <<< "isc-dhcp-relay isc-dhcp-relay/interfaces string eth1 eth2"
    debconf-set-selections <<< "isc-dhcp-relay isc-dhcp-relay/options string -m append -c 3"
    apt-get install isc-dhcp-relay -y
    debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true"
    debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true"
    sudo apt-get install iptables-persistent -y
    apt-get install tcpdump -y
    apt-get install nginx -y
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
    systemctl stop systemd-resolved
    systemctl disable systemd-resolved

    rm /etc/resolv.conf
    touch /etc/resolv.conf
    echo "search rocca.local
nameserver 172.16.24.62" > /etc/resolv.conf
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


#Firewall configuration:
firewall_config() {
    systemctl stop firewalld
    systemctl disable firewalld

    MAN=eth0
    UPLINK=eth1
    DOWNLINK=eth2

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
    iptables -A INPUT -i $DOWNLINK -j ACCEPT
    iptables -A OUTPUT -o $DOWNLINK -j ACCEPT

    # Allow pings:
    iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

    iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
    iptables -A OUTPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
    iptables -A OUTPUT -p icmp --icmp-type time-exceeded -j ACCEPT
    iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

    iptables -A FORWARD -p icmp --icmp-type echo-reply -j ACCEPT
    iptables -A FORWARD -p icmp --icmp-type destination-unreachable -j ACCEPT
    iptables -A FORWARD -p icmp --icmp-type time-exceeded -j ACCEPT
    iptables -A FORWARD -p icmp --icmp-type echo-request -j ACCEPT

    #Open access to the Internet for router:
    iptables -A OUTPUT -o $UPLINK -j ACCEPT

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

    #Allow dhcp traffic:
    iptables -A INPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT
    iptables -A OUTPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT
    iptables -A FORWARD -p udp --dport 67:68 --sport 67:68 -j ACCEPT

    #Block access from DMZ to local networks:
    iptables -A INPUT -s 172.16.24.248/29 -d 172.16.24.64/27 -j REJECT
    iptables -A INPUT -s 172.16.24.248/29 -d 172.16.24.96/29 -j REJECT

    #Forward port into local network:
   # iptables -t nat -A PREROUTING -p tcp --dport 80 -i $WAN -j DNAT --to 172.16.24.254:80
   # iptables -A FORWARD -i $WAN -p tcp -m tcp --dport 80 -j ACCEPT

    #Allow access from local net to outside:
   # iptables -A FORWARD -s 172.16.24.248/29 -d 172.16.24.1 -j ACCEPT
    #Close access from outside to LAN:
   # iptables -A FORWARD -i $WAN -o $LAN -j REJECT

    #Open access to SSH:
    iptables -A INPUT -i $UPLINK -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -i $MAN -p tcp --dport 22 -j ACCEPT

    #Open access to Web-server(Nginx-balancer from Internet and directly to Nginx Web-server from LAN):
    iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
    iptables -A FORWARD -p tcp -m tcp --dport 80 -j ACCEPT

    #Open access to DNS-server:
    iptables -A INPUT -p udp --dport 53 -j ACCEPT
    iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
    iptables -A FORWARD -p udp --dport 53 -j ACCEPT

    #Save rules:
    mkdir /etc/iptables
    touch /etc/iptables/rules.v4
    /sbin/iptables-save  > /etc/iptables/rules.v4
}


#Routing configuration:
routing_config() {
    ip route del default via 10.0.2.2

    touch /etc/sysconfig/network-scripts/route-eth1
    echo '172.16.24.96/29 via 172.16.24.61
172.16.24.64/27 via 172.16.24.60' > /etc/sysconfig/network-scripts/route-eth1
}


#DHCP-relay configuration:
dhcrelay_config() {
#    change-config-file "" "SERVERS" "=" "172.16.24.62" "/etc/default/isc-dhcp-relay"
#    change-config-file "" "INTERFACES" "=" "\"eth1 eth2\"" "/etc/default/isc-dhcp-relay"
#    change-config-file "" "OPTIONS" "=" "\"-m append -c 3\"" "/etc/default/isc-dhcp-relay"
#    dhcrelay -m append -c 3 -i eth1 -i eth2 172.16.24.62
    systemctl restart isc-dhcp-relay
    systemctl enable isc-dhcp-relay
}


#NGINX balancer configuration:
nginx_config() {
    systemctl enable nginx

    cp /etc/nginx/nginx.conf{,.bak}
    echo 'user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
        # multi_accept on;
}

http {

        ##
        # Basic Settings
        ##

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        # server_tokens off;

        # server_names_hash_bucket_size 64;
        # server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ##
        # SSL Settings
        ##

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        ##
        # Logging Settings
        ##

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        ##
        # Gzip Settings
        ##

        gzip on;

        # gzip_vary on;
        # gzip_proxied any;
        # gzip_comp_level 6;
        # gzip_buffers 16 8k;
        # gzip_http_version 1.1;
        # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss tex>
        ##
        # Virtual Host Configs
        ##

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;


    server {
        listen       80;
        listen       [::]:80;
        server_name  roccatech.net www.roccatech.net;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;

        proxy_cache             off;
        proxy_redirect          off;
        proxy_pass http://roccatech.net/;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
}

#mail {
#       # See sample authentication script at:
#       # http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
#
#       # auth_http localhost/auth.php;
#       # pop3_capabilities "TOP" "USER";
#       # imap_capabilities "IMAP4rev1" "UIDPLUS";
#
#       server {
#               listen     localhost:110;
#               protocol   pop3;
#               proxy      on;
#       }
#
#       server {
#               listen     localhost:143;
#               protocol   imap;
#               proxy      on;
#       }
#}' > /etc/nginx/nginx.conf

    systemctl restart nginx

}


apt_install
ip4_forwarding_enable
resolv_config
interfaces_config
firewall_config
routing_config
dhcrelay_config
nginx_config

exit 0