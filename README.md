# Kubernetes on Hyper-V
Kubernetes multi node cluster on Hyper-V

Prerequisites
- Hyper-V role enabled
- Vagrant

## Create Kubernetes cluster
Open a powershell command in admin mode.

### Create hyper-v virtual switch
```powershell
# Launch as Admin
.\create-vswitch.ps1
```

### Minimal cluster

```powershell
# Create the cluster as defined in the Vagrantfile 
vagrant up 
```
Or

```powershell
# Create front end loadbalancer (advertise address)
vagrant up lb-01 

# Create master 1
vagrant up kube-1 

# Create worker 1
vagrant up kube-node-1 
```


### Custom cluster

Edit the `Vagrantfile` to shape your Kubernetes cluster
```ruby
#...
MASTER_COUNT = 3
NODE_COUNT   = 3
NFS_STORE    = true
#...
```

Execute
```powershell
vagrant up 
```

## Get the .kube\config file

The `.kube\config` file contains the credentials to connect on the cluster.

It is located on the Master node. You can copy it locally using the `scp` command

```powershell
scp -i keys/vagrant_rsa -o StrictHostKeyChecking=no vagrant@172.16.1.11:/home/vagrant/.kube/config cluster_config
```

If you encounter the following error on using the `scp` command 

>Permissions for 'keys/vagrant_rsa' are too open

Use the script below to restrict permissions on the `.\keys\vagrant_rsa` file.

```powershell
$keypath = ".\keys\vagrant_rsa"
$acl = Get-Acl $keypath 

# Disable inheritance
$acl.SetAccessRuleProtection($True, $False)

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, 'FullControl', 'Allow')
$acl.AddAccessRule($rule)

Set-Acl $keypath $acl | Out-Null
```

## Add nodes to the cluster

Once the master `kube-1` is created you can join nodes  as declared on the `Vagrantfile`

```powershell
# Create and join a new master (x is a number)
vagrant up kube-<x>
```
The same applies for workers

```powershell
# Create and join a new worker
vagrant up kube-node-<x>
```

## Expired secrets/certificates

The secret associated with the certificate used for joining new nodes has a short lifetime.

If the Master was created some times ago and the secret has expired, you will no longer be able to join new nodes.

Use this command to create a new certificate on an existing master

```powershell
vagrant provision "kube-1" --provision-with "renew-cert"
```

New nodes should be able to join

```powershell
# Retry join for a master node
vagrant provision "kube-<x>" --provision-with "rest-control-plane"

# Retry join for a worker node
vagrant provision "kube-node-<x>" --provision-with "worker-node"
```
