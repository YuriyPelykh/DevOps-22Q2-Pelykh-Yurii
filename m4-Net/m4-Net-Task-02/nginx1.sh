#!/usr/bin/env bash


#Packages installation with apt:
apt_install() {
    apt-get update
    apt-get install nginx -y
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

    ip link set eth1 up
    netplan --debug apply
}


#Firewall config:
firewall_config() {
    ufw app list
    ufw enable
    ufw allow 'Nginx HTTP'
    ufw allow ssh
    ufw status
}


#Nginx configuration:
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
        <h1>Success! The ${domain} server block is working!</h1>
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
                try_files \$uri \$uri/ =404;
        }
}" > /etc/nginx/sites-available/${domain}

    ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/

    cp /etc/nginx/nginx.conf{,.bak}
    change-config-file "" "server_names_hash_bucket_size" " " "64;" "/etc/nginx/nginx.conf"

    nginx -t
    systemctl restart nginx

}


#Routes adding:
routing_config() {
    ip route del default via 10.0.2.2
}


apt_install
resolv_config
interfaces_config
nginx_config
firewall_config
routing_config

exit 0
