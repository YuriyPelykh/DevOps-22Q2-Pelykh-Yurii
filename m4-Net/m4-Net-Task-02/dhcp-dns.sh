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
      addresses: [172.16.24.62/26]
      gateway4: 172.16.24.1
      nameservers:
        addresses: [127.0.0.1]
        search:
        - rocca.local" > /etc/netplan/02-netcfg.yaml

    ip link set ${INT1} up
    netplan apply
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


dhcp_server_config() {
    cp /etc/dhcp/dhcpd.conf{,.bak}
    echo 'ddns-update-style none;
authoritative;
default-lease-time 600;
max-lease-time 7200;


#class "net1" {
#  match if substring (option dhcp-client-identifier, 0, 4) = "net1";
#}

#class "net3" {
#  match if substring (option dhcp-client-identifier, 0, 4) = "net3";
#}

class "net1" {
  match if substring(hardware, 1, 3) = 08:08:27;
#  match if binary-to-ascii (16,8,":",substring(hardware, 0, 4)) = "1:08:08:27";
}

class "net3" {
  match if substring(hardware, 1, 3) = 08:00:27;
#  match if binary-to-ascii (16,8,":",substring(hardware, 0, 4)) = "1:08:00:27";
}


shared-network mynetwork {
  subnet 172.16.24.0 netmask 255.255.255.192 {
    pool {
      deny members of "net1";
      allow members of "net3";
      range 172.16.24.2 172.16.24.58;
      option routers 172.16.24.1;
      option subnet-mask 255.255.255.192;
      option broadcast-address 172.16.24.63;
      option domain-name "rocca.local";
      option domain-name-servers 172.16.24.62;
    }
  }

  subnet 172.16.24.96 netmask 255.255.255.248 {
    pool {
      deny members of "net3";
      allow members of "net1";
      range 172.16.24.98 172.16.24.102;
      option routers 172.16.24.97;
      option subnet-mask 255.255.255.248;
      option broadcast-address 172.16.24.103;
      option domain-name "rocca.local";
      option domain-name-servers 172.16.24.62;
    }

  }
}


host Rgw {
  hardware ethernet 08:00:27:9b:0d:35;
  fixed-address 172.16.24.1;
}

host r13up {
  hardware ethernet 08:00:27:9b:0d:26;
  fixed-address 172.16.24.61;
}

host r13down {
  hardware ethernet 08:08:27:9b:0d:27;
  fixed-address 172.16.24.97;
}' > /etc/dhcp/dhcpd.conf

    change-config-file "" "INTERFACESv4" "=" "${INT1}" "/etc/default/isc-dhcp-server"

    systemctl restart isc-dhcp-server
}


dns_server_config() {
    cp /etc/bind/named.conf.options{,.bak}
    echo 'options {
        directory "/var/cache/bind";
        dnssec-validation auto;

        listen-on-v6 { any; };

        listen-on {
          172.16.24.0/26;
          172.16.24.64/27;
          172.16.24.96/29;
        };

        allow-query { any; };

        forwarders {
          8.8.8.8;
        };
};' > /etc/bind/named.conf.options

    named-checkconf
    systemctl restart bind9

}


routing_config() {
    ip route del default via 10.0.2.2
    ip route add 172.16.24.96/29 via 172.16.24.61
    ip route add 172.16.24.64/27 via 172.16.24.60
}

apt_install
interfaces_config
dhcp_server_config
dns_server_config
routing_config

exit 0
