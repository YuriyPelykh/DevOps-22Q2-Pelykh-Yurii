#!/usr/bin/env bash

apt-get update

#apt-get install default-jre -y

install_docker() {
    apt-get remove docker docker-engine docker.io containerd runc
#    apt-get update
    apt-get install ca-certificates curl gnupg lsb-release -y
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    docker run hello-world

    groupadd docker
    usermod -aG docker $USER

}

interfaces_config() {
    touch /etc/netplan/02-netcfg.yaml
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
      addresses: [172.16.24.2/24]
      nameservers:
        addresses: [8.8.8.8]" > /etc/netplan/02-netcfg.yaml

    ip link set eth1 up
    netplan apply
}

interfaces_config
install_docker