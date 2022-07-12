#!/usr/bin/env bash

INT1="eth1"


apt_install () {
    apt-get update
    apt-get install isc-dhcp-server bind9 bind9utils -y
}

interfaces_config() {
    touch /etc/netplan/02-netcfg.yaml
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    ${INT1}:
      addresses: [172.16.24.253/24]
      gateway4: 172.16.24.254
      nameservers:
        addresses: [127.0.0.1]
        search:
        - rocca.local" > /etc/netplan/02-netcfg.yaml

    ip link set ${INT1} up
    netplan apply
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


dhcp_server_config() {
    echo "subnet 172.16.24.0 netmask 255.255.255.0 {
     range 172.16.24.1 172.16.24.100;
     option subnet-mask 255.255.255.0;
     option broadcast-address 172.16.24.255;
     option domain-name-servers 172.16.24.253;
     option domain-name \"rocca.local\";
     option routers 172.16.24.254;
     default-lease-time 7200;
     max-lease-time 480000;

     host Rgw {
      hardware ethernet 08:00:27:9b:0d:35;
      fixed-address 172.16.24.254;
     }

     host R13up {
      hardware ethernet 08:00:27:9b:0d:26;
      fixed-address 172.16.24.250;
     }
}

subnet 172.16.23.0 netmask 255.255.255.0 {
     range 172.16.23.1 172.16.23.100;
     option subnet-mask 255.255.255.0;
     option broadcast-address 172.16.23.255;
     option domain-name-servers 172.16.24.253;
     option domain-name \"rocca.local\";
     option routers 172.16.23.254;
     default-lease-time 7200;
     max-lease-time 480000;

     host R13down {
      hardware ethernet 08:00:27:9b:0d:27;
      fixed-address 172.16.24.254;
     }
}" >> /etc/dhcp/dhcpd.conf

    change-config-file "" "INTERFACESv4" "=" "${INT1}" "/etc/default/isc-dhcp-server"

    systemctl restart isc-dhcp-server
}


dns_server_config() {
    cp /etc/bind/named.conf.options{,.bak}
    echo "listen-on {
    172.16.24.0/24;
};

allow-query { any; };

forwarders {
    8.8.8.8;
    8.8.4.4;
};" >> /etc/bind/named.conf.options

    named-checkconf
    systemctl restart bind9

}


routing_config() {
    ip route del default via 10.0.2.2
}

apt_install
interfaces_config
dhcp_server_config
routing_config

exit 0
