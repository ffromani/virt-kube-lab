# !/bin/bash
set -e
## REPOS
# TODO: set up k8s repo

## SELinux
# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

## Kernel
# setup kernel parameters needed/recommended by k8s
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
# setup kernel modules needed/recommended by k8s
cat <<EOF > /etc/modules-load.d/k8s.conf
br_netfilter
EOF
modprobe br_netfilter

## Firewalld
# TODO: disable and mask firewalld

## SWAP
# TODO: DISABLE SWAP
