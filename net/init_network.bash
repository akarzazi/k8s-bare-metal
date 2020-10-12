echo "init network
ip          $1 
mask        $2 
gateway4    $3 
dns         $4"

cat > /etc/netplan/01-netcfg.yaml <<EOL
network:
  version: 2
  ethernets:
      eth0:
          addresses: [$1/$2]
          gateway4: $3
          optional: true
          nameservers:
              addresses: [$4]

EOL

netplan apply