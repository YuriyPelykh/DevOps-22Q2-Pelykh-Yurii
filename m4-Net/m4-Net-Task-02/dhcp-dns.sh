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


class "net1" {
  match if substring(hardware, 1, 3) = 08:08:27;
}

class "net2" {
  match if substring(hardware, 1, 3) = 08:0b:27;
}

class "net3" {
  match if substring(hardware, 1, 3) = 08:00:27;
}

class "netdmz" {
  match if substring(hardware, 1, 3) = 08:0a:27;
}


shared-network mynetwork {
  subnet 172.16.24.0 netmask 255.255.255.192 {
    option routers 172.16.24.1;
    option subnet-mask 255.255.255.192;
    option broadcast-address 172.16.24.63;
    option domain-name-servers 172.16.24.62;
    option domain-name "rocca.local";
    pool {
      allow members of "net3";
      range 172.16.24.2 172.16.24.58;
    }
  }

  subnet 172.16.24.64 netmask 255.255.255.224 {
    option routers 172.16.24.65;
    option subnet-mask 255.255.255.224;
    option broadcast-address 172.16.24.95;
    option domain-name-servers 172.16.24.62;
    option domain-name "rocca.local";
    pool {
      allow members of "net2";
      range 172.16.24.66 172.16.24.94;
    }
  }

  subnet 172.16.24.96 netmask 255.255.255.248 {
    option routers 172.16.24.97;
    option subnet-mask 255.255.255.248;
    option broadcast-address 172.16.24.103;
    option domain-name-servers 172.16.24.62;
    option domain-name "rocca.local";
    pool {
      allow members of "net1";
      range 172.16.24.98 172.16.24.102;
     }
  }

  subnet 172.16.24.248 netmask 255.255.255.248 {
    option routers 172.16.24.249;
    option subnet-mask 255.255.255.248;
    option broadcast-address 172.16.24.255;
    option domain-name-servers 172.16.24.62;
    option domain-name "rocca.local";
    pool {
      allow members of "netdmz";
      range 172.16.24.250 172.16.24.252;
    }
  }
}


host Rgw {
  hardware ethernet 08:00:27:9b:0d:35;
  fixed-address 172.16.24.1;
#  option domain-name-servers 172.16.24.62;
#  option domain-name "rocca.local";
#  option subnet-mask 255.255.255.192;
#  option broadcast-address 172.16.24.63;
}

host r13up {
  hardware ethernet 08:00:27:9b:0d:26;
  fixed-address 172.16.24.61;
#  option domain-name-servers 172.16.24.62;
#  option domain-name "rocca.local";
#  option routers 172.16.24.1;
#  option subnet-mask 255.255.255.192;
#  option broadcast-address 172.16.24.63;
}

host rdmz3up {
  hardware ethernet 08:00:27:9b:0d:24;
  fixed-address 172.16.24.59;
#  option domain-name-servers 172.16.24.62;
#  option domain-name "rocca.local";
#  option routers 172.16.24.1;
#  option subnet-mask 255.255.255.192;
#  option broadcast-address 172.16.24.63;
}

host nginx1 {
  hardware ethernet 08:0a:27:9b:0d:22;
  fixed-address 172.16.24.254;
#  option domain-name-servers 172.16.24.62;
#  option domain-name "rocca.local";
#  option routers 172.16.24.249;
#  option subnet-mask 255.255.255.248;
#  option broadcast-address 172.16.24.255;
}

host nginx2 {
  hardware ethernet 08:0a:27:9b:0d:21;
  fixed-address 172.16.24.253;
}
' > /etc/dhcp/dhcpd.conf

    cp /etc/default/isc-dhcp-server{,.bak}
    change-config-file "" "INTERFACESv4" "=" "${INT1}" "/etc/default/isc-dhcp-server"

    systemctl restart isc-dhcp-server
}


dns_server_config() {
    cp /etc/systemd/resolved.conf{,.bak}
    echo '[Resolve]
DNS=127.0.0.1
FallbackDNS=
DNSSEC=no
LLMNR=resolve
DNSStubListener=no' > /etc/systemd/resolved.conf

    systemctl restart systemd-resolved

    cp /etc/bind/named.conf.options{,.bak}
    echo 'options {
        directory "/var/cache/bind";
        dnssec-validation auto;

        listen-on {
          localhost;
          127.0.0.1;
          172.16.24.62;
        };

        allow-query { any; };

        forwarders {
          8.8.8.8;
          4.4.2.2;
        };
};' > /etc/bind/named.conf.options

    cp /etc/bind/named.conf.local{,.bak}
    echo'zone "rocca.local" {
        type master;
        file "master/rocca.local";
        allow-transfer { none; };
        allow-update {
          172.16.24.0/26;
          172.16.24.64/27;
          172.16.24.96/29;
          172.16.24.248/29;
        };
};

zone "24.16.172.in-addr.arpa" {
    type master;
    file "master/24.16.172.zone";
};' > /etc/bind/named.conf.local

    mkdir /var/cache/bind/master
    touch /var/cache/bind/master/rocca.local
    echo'$TTL 14400

rocca.local.    IN      SOA     ns.rocca.local. root.rocca.local. (
        2022071601      ; Serial
        10800           ; Refresh
        3600            ; Retry
        604800          ; Expire
        604800 )        ; Negative Cache TTL


@               IN      NS      ns.rocca.local.
localhost       IN      A       127.0.0.1
ns              IN      A       172.16.24.62' > /var/cache/bind/master/rocca.local

    touch /var/cache/bind/master/24.16.172.zone
    echo'$TTL    3600
@  IN      SOA     rooca.local. root.rocca.local (
                   20060204        ; Serial
                   3600            ; Refresh
                   900             ; Retry
                   3600000         ; Expire
                   3600 )          ; Minimum
   IN      NS      ns.rocca.local.
62 IN      PTR     ns.rocca.local.' > /var/cache/bind/master/24.16.172.zone

    named-checkconf
    systemctl restart named
    systemctl enable named.service

}


routing_config() {
    ip route del default via 10.0.2.2
    ip route add 172.16.24.96/29 via 172.16.24.61
    ip route add 172.16.24.64/27 via 172.16.24.60
    ip route add 172.16.24.248/29 via 172.16.24.59
}


apt_install
interfaces_config
dhcp_server_config
dns_server_config
routing_config

exit 0
