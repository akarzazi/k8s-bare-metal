# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

BOX_IMAGE    = "bento/ubuntu-20.04"
PROVIDER     = "hyperv"

NET_TYPE     = "private_network"
NET_SWITCH   = "NATSwitch"
NET_GATEWAY  = "172.21.21.1"
NET_MASK_NUM = "24"
NET_DNS     = "1.1.1.1"

NODE_IP_NW   = "172.21.21."
LB_IP        = "172.21.12.200"

MASTER_COUNT = 3
NODE_COUNT   = 3
NFS_STORE    = true
HA_PROXY     = true

def configure_base(vm,name,ip)
    vm.hostname = name

    vm.provider PROVIDER do |h|
      h.memory = 1024
      h.cpus = 2
      h.enable_virtualization_extensions = true
      h.linked_clone = true
      h.vmname = name
    end
  
    vm.network NET_TYPE, bridge: NET_SWITCH, ip: ip, auto_config: false

    vm.provision "net" , type: "shell", preserve_order: true do |s|
      s.path = "net/init_network.bash"
      s.args = [ip, NET_MASK_NUM, NET_GATEWAY , NET_DNS]
    end
end

Vagrant.configure("2") do |config|
  config.vm.box = BOX_IMAGE
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.ssh.insert_key = false
  config.vm.provision "copy-rsa", type:"file", source: "keys/vagrant_rsa", destination: "/home/vagrant/.ssh/vagrant_rsa"
  config.vm.provision "copy-rsa-pub", type:"file", source: "keys/vagrant_rsa.pub", destination: "/home/vagrant/.ssh/vagrant_rsa.pub"
  config.vm.provision "config-rsa", type:"shell", inline: <<-SHELL
    cat /home/vagrant/.ssh/vagrant_rsa.pub >> /home/vagrant/.ssh/authorized_keys
    chmod 600 /home/vagrant/.ssh/vagrant_rsa
  SHELL

  if NFS_STORE
    config.vm.define "nfs-01" do |srv|
      configure_base(srv.vm,"nfs-01","172.21.21.150")
      srv.vm.provision "nfs",  type: "shell", path: "init_nfs.bash", preserve_order: true 
    end
  end

  if HA_PROXY
    config.vm.define "lb-01" do |srv|
      configure_base(srv.vm,"lb-01","172.21.21.200")
      srv.vm.provision "haproxy", type: "shell", path: "init_haproxy.bash", preserve_order: true 
    end
  end

  (1..MASTER_COUNT).each do |i|
    config.vm.define "kube-#{i}" do |srv|
      configure_base(srv.vm,"kube-#{i}","#{NODE_IP_NW}" + "#{i + 10}")

      srv.vm.provider PROVIDER do |h|
        h.memory = 2048
      end

      srv.vm.provision "init-kube", type: "shell", path: "k8s/init-kube.bash"
  
      if i == 1
        srv.vm.provision "first-control-plane", type: "shell", path: "k8s/first-control-plane.bash"
      else  
        srv.vm.provision "rest-control-plane", type: "shell", path: "k8s/rest-control-plane.bash"
      end

      srv.vm.provision "renew-cert", type: "shell", path: "k8s/renew-cert.bash", run: "never"
    end
  end

  (1..NODE_COUNT).each do |i|
    config.vm.define "kube-node-#{i}" do |srv|
      configure_base(srv.vm,"kube-node-#{i}","#{NODE_IP_NW}" + "#{i + 20}")
      srv.vm.provision "init-kube", type: "shell", path: "k8s/init-kube.bash"
      srv.vm.provision "worker-node", type: "shell", path: "k8s/worker-node.bash"
    end
  end

end
