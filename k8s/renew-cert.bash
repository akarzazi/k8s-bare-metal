#!/bin/bash
set -eo pipefail

echo "[TASK 1] Create new certificate key"
CERT_KEY="$(kubeadm alpha certs certificate-key)"

echo "[TASK 2] New certificate"
kubeadm init phase upload-certs --upload-certs --certificate-key $CERT_KEY

echo "[TASK 3] Generate join files"
{
    kubeadm token create --print-join-command --certificate-key $CERT_KEY 2>/dev/null > /tmp/join-master.sh
    kubeadm token create --print-join-command  2>/dev/null > /tmp/join-worker.sh
}