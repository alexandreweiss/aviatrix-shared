#!/usr/bin/env bash
set -euo pipefail

# Check if VM name is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <vm-name> [site]"
    echo "Example: $0 edge-gw-01"
    echo "Example: $0 edge-gw-01 mumbai"
    echo "Default site: india"
    exit 1
fi

VM_NAME="$1"
SITE="${2:-india}"  # Default to india if not provided
SOURCE_IMAGE="/virtu/iso/avx-gateway-g4-202507291722.qcow2"
AVIATRIX_ISO="/mnt/edge-isos/${VM_NAME}-${SITE}.iso"
VM_DISK="/virtu/vm/${VM_NAME}.qcow2"
VM_DIR="/virtu/vm"

# Validate VM name (alphanumeric, hyphens, underscores only)
if [[ ! "$VM_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: VM name can only contain letters, numbers, hyphens, and underscores"
    exit 1
fi

# Check if source image exists
if [[ ! -f "$SOURCE_IMAGE" ]]; then
    echo "Error: Source image not found at $SOURCE_IMAGE"
    exit 1
fi

# Check if Aviatrix ISO exists
if [[ ! -f "$AVIATRIX_ISO" ]]; then
    echo "Error: Aviatrix ISO not found at $AVIATRIX_ISO"
    echo "Please ensure the Aviatrix Edge ISO is available in /mnt/edge-isos/"
    echo "Expected filename: ${VM_NAME}-${SITE}.iso"
    exit 1
fi

# Check if VM already exists
if virsh list --all | grep -q " $VM_NAME "; then
    echo "Error: VM '$VM_NAME' already exists"
    exit 1
fi

# Check if disk already exists
if [[ -f "$VM_DISK" ]]; then
    echo "Error: Disk file '$VM_DISK' already exists"
    exit 1
fi

echo "Creating Aviatrix Edge Gateway VM: $VM_NAME"
echo "Using site: $SITE"
echo "Source image: $SOURCE_IMAGE"
echo "Aviatrix ISO: $AVIATRIX_ISO"

# Create VM directory if it doesn't exist
mkdir -p "$VM_DIR"

# Copy source image as VM disk
echo "Creating VM disk from source image..."
cp "$SOURCE_IMAGE" "$VM_DISK"
chown libvirt-qemu:kvm "$VM_DISK"
chmod 644 "$VM_DISK"

# Set VM specifications
VM_MEMORY=4096  # 4GB RAM
VM_VCPUS=2      # 2 vCPUs

# Create the VM with virt-install
echo "Creating VM with virt-install..."
virt-install \
    --name="$VM_NAME" \
    --vcpus="$VM_VCPUS" \
    --memory="$VM_MEMORY" \
    --disk path="$VM_DISK",format=qcow2,bus=virtio \
    --disk path="$AVIATRIX_ISO",device=cdrom,bus=sata,readonly=on \
    --network network=wan,model=virtio \
    --network network=lan,model=virtio \
    --network network=mgmt,model=virtio \
    --graphics vnc,listen=0.0.0.0,port=-1 \
    --console pty,target_type=serial \
    --boot hd,cdrom \
    --os-variant=ubuntu22.04 \
    --noautoconsole \
    --autostart

echo ""
echo "Aviatrix Edge Gateway VM '$VM_NAME' created successfully!"
echo ""
echo "VM Details:"
echo "  Name: $VM_NAME"
echo "  Memory: ${VM_MEMORY} MB"
echo "  vCPUs: $VM_VCPUS"
echo "  Disk: $VM_DISK"
echo "  Networks: WAN, LAN, MGMT"
echo "  Site: $SITE"
echo ""
echo "The VM will boot from the Aviatrix Edge Gateway image and the configuration ISO."
echo "Check Cockpit web interface for VM status and console access."