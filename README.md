# Kubernetes on Virtual Machines on your home lab

## Introduction
WRITEME

## hardware
TODO

### host/lan setup


### Provision golden image for virtual machines
```bash
virt-builder -o /var/lib/libvirt/images/c7-base-0.qcow2 --size=80G --format qcow2 --ssh-inject root:file:kojiro-kube-lan.pub --update --selinux-relabel --root-password file:rootpw centos-7.6
```

### Provision virtual machines

Clone the disks:
```bash
cp -a /var/lib/libvirt/images/c7-base-0.qcow2 /var/lib/libvirt/images/c7-allinone-0.qcow2
```


#### Provision for All-in-One:
```bash
virt-install --name c7-allinone-0 --ram 6144 --vcpus 4 --cpu host --os-type linux --os-variant centos7.0 --disk path=/var/lib/libvirt/images/c7-allinone-0.qcow2,device=disk,bus=virtio,format=qcow2 --network bridge=k8sbr0,model=virtio --graphics none --console pty,target_type=serial --import
```

### Set up DNS, IP
```bash
# TODO: dns
virsh qemu-agent-command c7-allinone-0 '{"execute":"guest-network-get-interfaces"}' | python -mjson.tool
# TODO: poweroff
ssh -oStrictHostKeyChecking=no root@192.168.224.29 hostnamectl set-hostname c7-allinone-0.kube.lan
```

### Install base packages
```bash
ssh -oStrictHostKeyChecking=no root@192.168.224.29 << SSHEOF
yum -y install net-tools vim-enhanced htop atop wget
SSHEOF
```

## Kubernetes

### Configure for Kubeadm
```bash
# set up repo
## Set SELinux in permissive mode (effectively disabling it)
#setenforce 0
#sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
# cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
ssh root@c7-allinone-0 sysctl --system
# cat <<EOF > /etc/modules-load.d/k8s.conf
br_netfilter
EOF
# load br_netfilter
# disable and mask firewalld
# DISABLE SWAP
```

### Install required packages

```bash
ssh -oStrictHostKeyChecking=no root@192.168.224.29 yum install -y docker
ssh root@c7-allinone-0 yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```

```bash
ssh root@c7-allinone-0 systemctl enable --now docker
ssh root@c7-allinone-0 systemctl enable --now kubelet
```

### Run kubeadm

```bash
ssh root@c7-allinone-0 kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=swap
```

### Configure the host ass All-in-One

TODO: (un)taint node

