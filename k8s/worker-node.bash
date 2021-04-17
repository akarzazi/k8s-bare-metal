#!/bin/bash
set -eo pipefail
VAGRANT_HOME="/home/vagrant"

echo "[TASK 1] Reset"
kubeadm reset -f

echo "[TASK 2] Copy join worker command"
scp -i $VAGRANT_HOME/.ssh/vagrant_rsa -o StrictHostKeyChecking=no vagrant@172.16.1.11:/tmp/join-worker.sh /tmp/join-worker.sh

echo "[TASK 3] Exec join worker command"
bash /tmp/join-worker.sh

echo "[TASK 4] Add kubeconfig to vagrant"
mkdir -p $VAGRANT_HOME/.kube
scp -i $VAGRANT_HOME/.ssh/vagrant_rsa -o StrictHostKeyChecking=no vagrant@172.16.1.11:$VAGRANT_HOME/.kube/config $VAGRANT_HOME/.kube/config
chmod 644 $VAGRANT_HOME/.kube/config

# Nfs client
#apt install nfs-common -y