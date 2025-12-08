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

# Ensure VM directory exists
mkdir -p "$VM_DIR"

echo "Creating virtual machine: $VM_NAME"
echo "Site: $SITE"
echo "Source image: $SOURCE_IMAGE"
echo "Aviatrix ISO: $AVIATRIX_ISO"
echo "VM disk: $VM_DISK"

# Copy the source image to create VM disk
echo "Copying Aviatrix image to VM disk..."
cp "$SOURCE_IMAGE" "$VM_DISK"

# Set proper ownership and permissions
chown libvirt-qemu:kvm "$VM_DISK"
chmod 644 "$VM_DISK"

# Create the VM with virt-install
echo "Creating VM with virt-install..."
virt-install \
    --name="$VM_NAME" \
    --vcpus=2 \
    --memory=2048 \
    --disk path="$VM_DISK",format=qcow2,bus=virtio \
    --network network=wan,model=virtio \
    --network network=lan,model=virtio \
    --network network=mgmt,model=virtio \
    --disk path="$AVIATRIX_ISO",device=cdrom,bus=sata,readonly=on \
    --graphics vnc,listen=0.0.0.0,port=-1 \
    --console pty,target_type=serial \
    --boot hd,cdrom \
    --os-variant=generic \
    --noautoconsole \
    --print-xml > /home/admin-lab/${VM_NAME}.xml

# Define the VM from XML
echo "Defining VM..."
virsh define /home/admin-lab/${VM_NAME}.xml

# Enable autostart
virsh autostart "$VM_NAME"

# Clean up temporary XML file
rm -f /home/admin-lab/${VM_NAME}.xml

echo ""
echo "Virtual machine '$VM_NAME' created successfully (not started)!"
echo ""
echo "VM Details:"
echo "  Name: $VM_NAME"
echo "  Site: $SITE"
echo "  Memory: 2048 MB"
echo "  vCPUs: 2"
echo "  Disk: $VM_DISK"
echo "  Networks: wan, lan, mgmt (in that order)"
echo "  Aviatrix ISO: $AVIATRIX_ISO"
echo "  VNC Graphics: Enabled"
echo "  Autostart: Enabled"
echo "  Status: Defined but not started"
echo ""

# Show VM info
virsh dominfo "$VM_NAME"

echo ""
echo "To attach an ISO to the CD/DVD drive:"
echo "  virsh attach-disk $VM_NAME /path/to/your.iso hdb --type cdrom --mode readonly"
echo "To start the VM: virsh start $VM_NAME"
echo "To connect via console: virsh console $VM_NAME"
echo "To get VNC port: virsh vncdisplay $VM_NAME"
echo "To destroy the VM: virsh destroy $VM_NAME && virsh undefine $VM_NAME --remove-all-storage"