#!/usr/bin/env bash

interfaces_config() {
    touch /etc/netplan/02-netcfg.yaml
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
        dhcp4: true
#      addresses: [192.168.20.1/24]
#      gateway4: 172.16.24.1" > /etc/netplan/02-netcfg.yaml

    ip link set eth1 up
    netplan apply
}

docker_install() {
    # Install packages:
    sudo apt-get remove docker docker-engine docker.io containerd runc -y

    #Update the apt package index and install packages:
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg -y

    # Add Docker’s official GPG key:
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up the repository:
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the apt package index:
    sudo apt-get update

    # Install Docker Engine, containerd, and Docker Compose:
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    # Install docker-compose
    sudo apt install docker-compose -y

    # Exec from vagrant user:
    sudo groupadd docker
    sudo usermod -a -G docker vagrant

    # Set max_map_count (required for successful elk container start): 
    sudo sysctl -w vm.max_map_count=262144
}

interfaces_config
docker_install

exit 0
