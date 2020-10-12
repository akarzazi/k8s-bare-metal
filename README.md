# Kubernetes on Hyper-V
Kubernetes multi node cluster on Hyper-V

Prerequisites
- Hyper-V role enabled
- Vagrant

## Create Kubernetes cluster
Open a powershell command in admin mode.

### Create hyper-v virtual switch
```powershell
.\create-vswitch.ps1
```

### Minimal cluster
```bash
# Create front end loadbalancer (advertise address)
vagrant up lb-01 

# Create master 1
vagrant up kube-1 

# Create worker 1
vagrant up kube-node-1 
```

### Full cluster

```bash
# Creates all machines in the vagrant file
# 3 masters / 3 workers / 1 lb / 1 nfs store
vagrant up 
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
```bash
vagrant up 
```

## Add nodes to the cluster

Once the master `kube-1` is created you can join as many masters as declared on the `Vagrantfile`

```bash
# Create and join a new master (where x > 1)
vagrant up kube-(x) 
```
The same applies for workers

```bash
# Create and join a new worker (where x > 1)
vagrant up kube-node-(x) 
```

*Expired secrets/certificates*

The secret associated with the certificate used for joining new nodes has a short lifetime.

If the Master was created some times ago and the secret has expired, you will no longer be able to join new nodes.

Use this command to create a new certificate on an existing master

```bash
vagrant provision "kube-1" --provision-with "renew-cert"
```

New nodes should be able to join

```bash
# Retry join for a master node
vagrant provision "kube-(x)" --provision-with "rest-control-plane"

# Retry join for a worker node
vagrant provision "kube-node-(x)" --provision-with "worker-node"
```
