#!/bin/bash

SSH_CONN="$1"
VM_NAME="$2"

VM_IFACES_JSON=$(ssh $SSH_CONN virsh qemu-agent-command ${VM_NAME} '{"execute":"guest-network-get-interfaces"}')
echo "VM_MACADDR=$(echo $VM_IFACES_JSON | jq -r '.return[1] | .["hardware-address"]')"
echo "VM_IPADDR=$(echo $VM_IFACES_JSON | jq -r '.return[1] | .["ip-addresses"][0] | .["ip-address"]')"
