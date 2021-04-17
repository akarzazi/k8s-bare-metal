#!/bin/bash
set -eo pipefail

VAGRANT_HOME="/home/vagrant"
MASTER_IP=`ip -o -4 addr show dev eth0 | sed 's/.* inet \([^/]*\).*/\1/'`
CONTROL_PLANE="172.16.1.200:6443"
POD_NW_CIDR="10.244.0.0/16"

CERT_KEY="$(kubeadm alpha certs certificate-key)"

echo "[TASK 1] Initialize Kubernetes Cluster"
kubeadm init    --control-plane-endpoint $CONTROL_PLANE \
                --upload-certs \
                --apiserver-advertise-address $MASTER_IP \
                --pod-network-cidr $POD_NW_CIDR \
                --certificate-key $CERT_KEY

echo "[TASK 2] Deploy Calico network"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.15/manifests/calico.yaml

echo "[TASK 3] Generate join files"
{
    kubeadm token create --print-join-command --certificate-key $CERT_KEY 2>/dev/null > /tmp/join-master.sh
    kubeadm token create --print-join-command  2>/dev/null > /tmp/join-worker.sh
}

echo "[TASK 4] Copy config to root .kube"
mkdir -p $HOME/.kube
cp -Rf /etc/kubernetes/admin.conf  $HOME/.kube/config
chown $(id -u):$(id -g)  $HOME/.kube/config

echo "[TASK 5] Copy config to vagrant user .kube"
mkdir -p $VAGRANT_HOME/.kube
cp $HOME/.kube/config  $VAGRANT_HOME/.kube/config
chmod 644 $VAGRANT_HOME/.kube/config

echo "[Final check] kubectl get nodes"
kubectl get nodes