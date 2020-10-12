echo "NFS server script"
apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install nfs-kernel-server
mkdir -p /export/volumes/pod
echo '/export/volumes *(rw,no_root_squash,no_subtree_check)' >> /etc/exports
echo "Get /etc/exports content"
cat /etc/exports
systemctl restart nfs-kernel-server.service