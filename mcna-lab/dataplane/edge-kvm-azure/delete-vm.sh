#!/usr/bin/env bash
set -euo pipefail

# Check if VM name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <vm-name>"
    echo "Example: $0 edge-gw-01"
    exit 1
fi

VM_NAME="$1"
VM_DISK="/virtu/vm/${VM_NAME}.qcow2"

# Validate VM name (alphanumeric, hyphens, underscores only)
if [[ ! "$VM_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: VM name can only contain letters, numbers, hyphens, and underscores"
    exit 1
fi

# Check if VM exists
if ! virsh list --all | grep -q " $VM_NAME "; then
    echo "Error: VM '$VM_NAME' does not exist"
    exit 1
fi

echo "Deleting virtual machine: $VM_NAME"

# Get VM state
VM_STATE=$(virsh domstate "$VM_NAME" 2>/dev/null || echo "unknown")
echo "Current VM state: $VM_STATE"

# If VM is running, destroy it first
if [[ "$VM_STATE" == "running" ]]; then
    echo "Stopping VM..."
    virsh destroy "$VM_NAME"
    echo "VM stopped"
fi

# Undefine the VM and remove all storage
echo "Removing VM definition and storage..."
virsh undefine "$VM_NAME" --remove-all-storage

# Additional cleanup: remove disk file if it still exists
if [[ -f "$VM_DISK" ]]; then
    echo "Removing remaining disk file: $VM_DISK"
    rm -f "$VM_DISK"
fi

echo ""
echo "Virtual machine '$VM_NAME' has been completely deleted!"
echo ""
echo "Cleanup completed:"
echo "  - VM definition removed"
echo "  - VM storage removed"
echo "  - Disk file removed: $VM_DISK"
echo ""

# Show remaining VMs
echo "Remaining VMs:"
virsh list --all