#!/usr/bin/env bash

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update

apt-get install default-jre -y
apt-get install jenkins -y

systemctl start jenkins
systemctl status jenkins
systemctl enable jenkins

cat /var/lib/jenkins/secrets/initialAdminPassword


interfaces_config() {
    touch /etc/netplan/02-netcfg.yaml
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
      addresses: [172.16.24.1/24]
      nameservers:
        addresses: [8.8.8.8]" > /etc/netplan/02-netcfg.yaml

    ip link set eth1 up
    netplan apply
}

interfaces_config