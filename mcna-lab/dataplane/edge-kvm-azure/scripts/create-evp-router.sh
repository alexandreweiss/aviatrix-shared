#!/usr/bin/env bash
set -euo pipefail

# Source the config file if it exists
if [[ -f /home/admin-lab/config.env ]]; then
    source /home/admin-lab/config.env
elif [[ -f /tmp/config.env ]]; then
    source /tmp/config.env
else
    echo "Error: Config file not found in /home/admin-lab/ or /tmp/"
    echo "Please ensure the VM was provisioned with cloud-init or copy config.env to /home/admin-lab/"
    exit 1
fi

# Check if VM name is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <vm-name> [site]"
    echo "Example: $0 evp-router-01"
    echo "Example: $0 evp-router-01 mumbai"
    echo "Default site: ${SITE}"
    exit 1
fi

VM_NAME="$1"
SITE_PARAM="${2:-${SITE}}"  # Use provided site or default from config
ISO_PATH="/virtu/iso/ubuntu-24.04.3-live-server-amd64.iso"
VM_DISK="/virtu/vm/${VM_NAME}.qcow2"
VM_DIR="/virtu/vm"
CLOUD_INIT_ISO="/virtu/vm/${VM_NAME}-cloud-init.iso"

# VM specifications
VM_MEMORY=2048  # 2GB RAM
VM_VCPUS=2      # 2 vCPUs
VM_DISK_SIZE="20G"

# Validate VM name
if [[ ! "$VM_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: VM name can only contain letters, numbers, hyphens, and underscores"
    exit 1
fi

# Check if Ubuntu ISO exists
if [[ ! -f "$ISO_PATH" ]]; then
    echo "Error: Ubuntu ISO not found at $ISO_PATH"
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

echo "Creating EVP Router VM: $VM_NAME"
echo "Using site: $SITE_PARAM"

# Create VM directory if it doesn't exist
mkdir -p "$VM_DIR"

# Network configuration based on workspace
ASN=$((65000 + WORKSPACE_ID))
ROUTER_ID="192.168.${WORKSPACE_ID}.1"
REMOTE_PEER_IP="192.168.${WORKSPACE_ID}.2"

# Create cloud-init user-data for EVP router
cat > "/tmp/${VM_NAME}-user-data" << EOF
#cloud-config
autoinstall:
  version: 1
  interactive-sections: []
  identity:
    hostname: ${VM_NAME}
    password: '\$6\$rounds=4096\$aQ7lsdeR4yeY\$lQ7lsdeR4yeY7lsdeR4yeY7lsdeR4yeY7lsdeR4yeY'
    username: admin-lab
  ssh:
    install-server: true
    allow-pw: true
  packages:
    - bird2
    - frr
    - iperf3
    - tcpdump
  late-commands:
    - chroot /target /bin/bash -c "echo 'admin-lab:admin-lab' | chpasswd"
  user-data:
    disable_root: false
    ssh_pwauth: true
    package_update: true
    package_upgrade: true
    packages:
      - bird2
      - frr
      - iperf3
      - tcpdump
    write_files:
      - content: |
          # BGP configuration for EVP Router
          router bgp ${ASN}
           bgp router-id ${ROUTER_ID}
           neighbor ${REMOTE_PEER_IP} remote-as 65100
           neighbor ${REMOTE_PEER_IP} description "Aviatrix Gateway"
           !
           address-family ipv4 unicast
            redistribute connected
            neighbor ${REMOTE_PEER_IP} activate
           exit-address-family
           !
        path: /etc/frr/bgpd.conf
        permissions: '0640'
        owner: frr:frr
      - content: |
          bgpd=yes
        path: /etc/frr/daemons
        permissions: '0640'
        owner: frr:frr
    runcmd:
      - systemctl enable frr
      - systemctl start frr
EOF

# Create cloud-init meta-data
cat > "/tmp/${VM_NAME}-meta-data" << EOF
instance-id: ${VM_NAME}
local-hostname: ${VM_NAME}
EOF

# Create cloud-init ISO
echo "Creating cloud-init ISO..."
# Create temp directory for ISO content with standard filenames
mkdir -p "/tmp/${VM_NAME}-iso"
cp "/tmp/${VM_NAME}-user-data" "/tmp/${VM_NAME}-iso/user-data"
cp "/tmp/${VM_NAME}-meta-data" "/tmp/${VM_NAME}-iso/meta-data"
genisoimage -output "$CLOUD_INIT_ISO" -volid cidata -joliet -rock "/tmp/${VM_NAME}-iso/user-data" "/tmp/${VM_NAME}-iso/meta-data"

# Create VM disk
echo "Creating VM disk..."
qemu-img create -f qcow2 "$VM_DISK" "$VM_DISK_SIZE"

# Set proper ownership
chown libvirt-qemu:kvm "$VM_DISK"
chown libvirt-qemu:kvm "$CLOUD_INIT_ISO"
chmod 644 "$VM_DISK"
chmod 644 "$CLOUD_INIT_ISO"

# Create the VM with virt-install
echo "Creating VM with virt-install..."
virt-install \
    --name="$VM_NAME" \
    --vcpus="$VM_VCPUS" \
    --memory="$VM_MEMORY" \
    --disk path="$VM_DISK",format=qcow2,bus=virtio \
    --disk path="$ISO_PATH",device=cdrom,bus=sata,readonly=on \
    --disk path="$CLOUD_INIT_ISO",device=cdrom,bus=sata,readonly=on \
    --network network=lan,model=virtio \
    --graphics vnc,listen=0.0.0.0,port=-1 \
    --console pty,target_type=serial \
    --boot hd,cdrom \
    --os-variant=ubuntu24.04 \
    --noautoconsole \
    --autostart

echo ""
echo "EVP Router VM '$VM_NAME' created successfully!"
echo ""
echo "VM Details:"
echo "  Name: $VM_NAME"
echo "  Memory: ${VM_MEMORY} MB"
echo "  vCPUs: $VM_VCPUS"
echo "  Disk: $VM_DISK"
echo "  Network: LAN"
echo "  BGP ASN: ${ASN}"
echo "  BGP Peer: ${REMOTE_PEER_IP}"
echo "  Router ID: ${ROUTER_ID}"
echo ""
echo "Login: admin-lab/ubuntu"

# Clean up temporary files
rm -f "/tmp/${VM_NAME}-user-data" "/tmp/${VM_NAME}-meta-data"
rm -rf "/tmp/${VM_NAME}-iso"