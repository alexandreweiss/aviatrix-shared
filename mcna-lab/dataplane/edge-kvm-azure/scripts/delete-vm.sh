#!/usr/bin/env bash
set -euo pipefail

# Check if VM name is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <vm-name>"
    echo "Example: $0 edge-gw-01"
    exit 1
fi

VM_NAME="$1"
VM_DISK="/virtu/vm/${VM_NAME}.qcow2"

# Check if VM exists
if ! virsh list --all | grep -q " $VM_NAME "; then
    echo "Error: VM '$VM_NAME' does not exist"
    echo "Available VMs:"
    virsh list --all
    exit 1
fi

echo "Deleting VM: $VM_NAME"

# Stop VM if running
if virsh list --state-running | grep -q " $VM_NAME "; then
    echo "Stopping VM..."
    virsh destroy "$VM_NAME"
fi

# Undefine VM (this removes it from libvirt)
echo "Removing VM definition..."
virsh undefine "$VM_NAME" --remove-all-storage --nvram || virsh undefine "$VM_NAME" --remove-all-storage

# Remove disk file if it exists
if [[ -f "$VM_DISK" ]]; then
    echo "Removing VM disk: $VM_DISK"
    rm -f "$VM_DISK"
fi

echo "VM '$VM_NAME' deleted successfully"