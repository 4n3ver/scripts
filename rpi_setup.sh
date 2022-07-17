#!/bin/bash

set -euo pipefail

# update system
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y \
    iperf3 \
    unattended-upgrades \
    samba \
    samba-common-bin

# create user
sudo adduser twen
sudo adduser twen sudo
su twen

# set hostname from "ubuntu"
sudo hostnamectl set-hostname rpi

# ssh with key
mkdir ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeg0V19TvmrVaeksM6CVO5nFlZy8NQr4xVI51I3eJsWbBolxp76661AGRo8QQls9emjhBoL6E3FOYVzt30isDORPdzwhrZnPfFECT81sHkG8lNgE1BtxFuiv6k1K9qPlTVyXPFuO1WCxW4fnkyg1IdzNtwN0Pj5o9XGdAZCItisZwMNP19E2EIv+bXZmb4I5SFaIXsBC3s9uNX7UkeyUeIkQjkKH27g8nFyrAHKR3eLV4g17UKWhNLNUoj5Zq4czsA9a4k/G4s6LwrYXr/rAVIUS1/ru/tnoNuR2E2qIc44DatlFwlS7QyvEnw83+R/XGZB7NsuirmQcbLGA5tpsZHhiZurq5moB9M6R/qHban+Q0excXayNnHB+nn+Xu0Vd487j80I+TeSH8bFc3cdFglvwtw8MY3Wt5GYAddzwlBbuAkR/IHoMdYIY19h9jHH6mWywUNK4Y1mqWqswUjLMP7MLfVUFgsv2VBboCbYH+4J4LbaXFE2sDkcBXUsRWtTeoGbnUQkdxGC2FEQNiMemyLeub4xmS0O73ZcruQ8hSo53uv2uanoXBnSXf2su1k3p/Q70jLW+Ge6XT98MNmssRISrM53u4uGx3y3aZDYyYNlJHBcUNVMZhqwvb3L/nfgx4Ac3z4yX+3Lz7cn/i4F1cSlqN7b4kDJscWGgFozHuLWQ== twen@4n3ver" > ~/.ssh/authorized_keys

# disable ssh with password
sudo sed -i -E "s/^#?(PasswordAuthentication)(.+)$/\1 no/" /etc/ssh/sshd_config
sudo sed -i -E "s/^#?(PermitEmptyPasswords)(.+)$/\1 no/" /etc/ssh/sshd_config
sudo sed -i -E "s/^#?(PermitRootLogin)(.+)$/#\1\2/" /etc/ssh/sshd_config

# require password on sudo
sudo sed -i -E "s/^(.+) (.+) NOPASSWD: ALL$/\1 \2 PASSWD: ALL/" /etc/sudoers.d/010_pi-nopasswd

# configure auto-upgrade
sudo tee -a /etc/apt/apt.conf.d/02periodic <<EOF
APT::Periodic::Enable "1";
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "1";
APT::Periodic::Verbose "2";
EOF

# disable swap
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo apt purge -y dphys-swapfile

# install k3s
curl -sfL https://get.k3s.io | sh -
sudo kubectl get nodes
kubectl create secret generic "some-credential" --from-literal=USER_NAME=uname --from-literal=PASSWORD=pwd

# configure traefik
sudo tee -a /var/lib/rancher/k3s/server/manifests/traefik-config.yaml <<EOF
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    ports:
      traefik:
        expose: false
      dns:
        port: 8053
        expose: true
        exposedPort: 53
        protocol: UDP
    dashboard:
      enabled: true
EOF

sudo reboot

### re-login before this, ssh twen@rpi

# remove default user
sudo deluser -remove-home pi

# change timezone
sudo dpkg-reconfigure tzdata

# setup samba https://pimylifeup.com/raspberry-pi-samba/
mkdir -p ~/shared
sudo nano /etc/samba/smb.conf
# [shared]
#    path = /home/twen/shared
#    writeable = Yes
#    create mask = 0700
#    directory mask = 0700
#    public = no

sudo smbpasswd -a twen
sudo systemctl restart smbd


### follow https://rancher.com/docs/k3s/latest/en/cluster-access/ for remote access
