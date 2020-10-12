#!/bin/bash
set -eo pipefail


DOCKER_VER="5:19.03.10~3-0~ubuntu-focal"
KUBE_VER="1.19.2"

export DEBIAN_FRONTEND=noninteractive

echo "[TASK 1] Disable firewall"
ufw disable

echo "[TASK 2] Disable swap"
swapoff -a; sed -i '/swap/d' /etc/fstab

echo "[TASK 3] update k8s networking settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo "[TASK 4] INSTALL DOCKER"
{
  apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt update && apt install -y docker-ce=$DOCKER_VER containerd.io
}

echo "[TASK 5] Configure DOCKER => systemd"

# Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker


echo "[TASK 6] Add apt k8s repo"
{
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
}

echo "[TASK 7] Install Kubernetes components"
apt update && apt install -y \
              kubeadm=$KUBE_VER-00 \
              kubelet=$KUBE_VER-00 \
              kubectl=$KUBE_VER-00
