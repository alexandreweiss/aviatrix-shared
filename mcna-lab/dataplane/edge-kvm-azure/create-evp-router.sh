#!/usr/bin/env bash
set -euo pipefail

# EVP Router VM Creation Script
# Creates an Ubuntu VM with FRR BGP configuration in KVM

# Default values
VM_NAME="evp-router"
VM_DIR="/virtu/vm"
ISO_DIR="/virtu/iso"
UBUNTU_ISO="ubuntu-24.04.3-live-server-amd64.iso"
SITE="india"
ASN=""
REMOTE_PEER_IP=""
VM_MEMORY=1024
VM_VCPUS=1
VM_DISK_SIZE="10G"
OS_TYPE="ubuntu24.04"

# Usage function
usage() {
    echo "Usage: $0 --asn <ASN> --peer <REMOTE_PEER_IP> [OPTIONS]"
    echo ""
    echo "Required arguments:"
    echo "  --asn <ASN>             BGP AS Number (e.g., 65001)"
    echo "  --peer <REMOTE_PEER_IP> Remote BGP peer IP (e.g., 172.22.2.5)"
    echo ""
    echo "Optional arguments:"
    echo "  --name <VM_NAME>        VM name (default: evp-router)"
    echo "  --memory <MB>           VM memory in MB (default: 1024)"
    echo "  --vcpus <COUNT>         VM vCPUs (default: 1)"
    echo "  --disk-size <SIZE>      VM disk size (default: 10G)"
    echo "  --iso <ISO_FILE>        Ubuntu ISO filename (default: ubuntu-24.04.3-live-server-amd64.iso)"
    echo "  --site <SITE>           Site name for ISO loading (default: india)"
    echo "  --os-type <OS_TYPE>     OS variant for virt-install (default: ubuntu24.04)"
    echo "  --help                  Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --asn 65001 --peer 172.22.2.5"
    echo "  $0 --asn 65002 --peer 172.22.3.5 --name router-02 --memory 2048"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --asn)
            ASN="$2"
            shift 2
            ;;
        --peer)
            REMOTE_PEER_IP="$2"
            shift 2
            ;;
        --name)
            VM_NAME="$2"
            shift 2
            ;;
        --memory)
            VM_MEMORY="$2"
            shift 2
            ;;
        --vcpus)
            VM_VCPUS="$2"
            shift 2
            ;;
        --disk-size)
            VM_DISK_SIZE="$2"
            shift 2
            ;;
        --iso)
            UBUNTU_ISO="$2"
            shift 2
            ;;
        --site)
            SITE="$2"
            shift 2
            ;;
        --os-type)
            OS_TYPE="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$ASN" ]]; then
    echo "Error: ASN is required"
    usage
    exit 1
fi

if [[ -z "$REMOTE_PEER_IP" ]]; then
    echo "Error: Remote peer IP is required"
    usage
    exit 1
fi

# Validate ASN is numeric
if ! [[ "$ASN" =~ ^[0-9]+$ ]] || [[ "$ASN" -lt 1 ]] || [[ "$ASN" -gt 4294967295 ]]; then
    echo "Error: ASN must be a number between 1 and 4294967295"
    exit 1
fi

# Validate IP address format
if ! [[ "$REMOTE_PEER_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Error: Invalid IP address format"
    exit 1
fi

# Set file paths
VM_DISK="$VM_DIR/${VM_NAME}.qcow2"
ISO_PATH="$ISO_DIR/$UBUNTU_ISO"
AVIATRIX_ISO="/mnt/edge-isos/${VM_NAME}-${SITE}.iso"
CLOUD_INIT_ISO="$VM_DIR/${VM_NAME}-cloud-init.iso"

echo "Creating EVP Router VM: $VM_NAME"
echo "Site: $SITE"
echo "ASN: $ASN"
echo "Remote Peer: $REMOTE_PEER_IP"
echo "Memory: ${VM_MEMORY}MB"
echo "vCPUs: $VM_VCPUS"
echo "Disk Size: $VM_DISK_SIZE"
echo "Aviatrix ISO: $AVIATRIX_ISO"

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

# Check if Ubuntu ISO exists
if [[ ! -f "$ISO_PATH" ]]; then
    echo "Error: Ubuntu ISO not found at $ISO_PATH"
    echo "Please download Ubuntu 24.04 LTS Server ISO to $ISO_DIR/"
    exit 1
fi

# Check if Aviatrix ISO exists
if [[ ! -f "$AVIATRIX_ISO" ]]; then
    echo "Error: Aviatrix ISO not found at $AVIATRIX_ISO"
    echo "Please ensure the Aviatrix Edge ISO is available in /mnt/edge-isos/"
    echo "Expected filename: ${VM_NAME}-${SITE}.iso"
    exit 1
fi

# Ensure VM directory exists
mkdir -p "$VM_DIR"

# Generate router ID from peer IP (use last octet + 100)
ROUTER_ID=$(echo "$REMOTE_PEER_IP" | awk -F. '{print $1"."$2"."$3"."($4+100)}')

# Create cloud-init user-data
cat > "/tmp/${VM_NAME}-user-data" << EOF
#cloud-config
hostname: ${VM_NAME}
manage_etc_hosts: true

# Default user
users:
  - name: admin-lab
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    shell: /bin/bash
    lock_passwd: false
    passwd: \$6\$rounds=4096\$saltsalt\$hash  # password: ubuntu
    ssh_authorized_keys: []

# Package installation
package_update: true
package_upgrade: true

packages:
  - frr
  - frr-pythontools
  - net-tools
  - tcpdump
  - traceroute
  - htop
  - vim

# Write FRR configuration files
write_files:
  - content: |
      # FRR daemons configuration
      bgpd=yes
      ospfd=no
      ospf6d=no
      ripd=no
      ripngd=no
      isisd=no
      pimd=no
      ldpd=no
      nhrpd=no
      eigrpd=no
      babeld=no
      sharpd=no
      pbrd=no
      bfdd=no
      fabricd=no
      vrrpd=no
    path: /etc/frr/daemons
    owner: frr:frr
    permissions: '0644'

  - content: |
      !
      ! BGP Configuration for EVP Router
      !
      hostname ${VM_NAME}
      password zebra
      enable password zebra
      !
      router bgp ${ASN}
       bgp router-id ${ROUTER_ID}
       bgp log-neighbor-changes
       !
       neighbor ${REMOTE_PEER_IP} remote-as 65000
       neighbor ${REMOTE_PEER_IP} description "Aviatrix Edge Gateway"
       neighbor ${REMOTE_PEER_IP} timers 30 90
       !
       address-family ipv4 unicast
        neighbor ${REMOTE_PEER_IP} activate
        neighbor ${REMOTE_PEER_IP} soft-reconfiguration inbound
       exit-address-family
      !
      line vty
       exec-timeout 0 0
      !
    path: /etc/frr/frr.conf
    owner: frr:frr
    permissions: '0644'

  - content: |
      !
      ! Zebra configuration
      !
      hostname ${VM_NAME}
      password zebra
      enable password zebra
      !
      line vty
       exec-timeout 0 0
      !
    path: /etc/frr/zebra.conf
    owner: frr:frr
    permissions: '0644'

# Configure network interface for LAN
runcmd:
  # Enable IP forwarding
  - echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
  - sysctl -p
  
  # Configure network interface (assuming first interface after loopback)
  - |
    cat > /etc/netplan/01-netcfg.yaml << 'NETPLAN_EOF'
    network:
      version: 2
      ethernets:
        enp1s0:
          dhcp4: yes
          dhcp4-overrides:
            use-routes: true
    NETPLAN_EOF
  
  # Apply network configuration
  - netplan apply
  
  # Start and enable FRR
  - systemctl enable frr
  - systemctl start frr
  
  # Wait a bit for FRR to start
  - sleep 5
  
  # Show BGP status
  - vtysh -c "show bgp summary"
  
  # Create useful scripts
  - |
    cat > /home/admin-lab/bgp-status.sh << 'BGP_STATUS_EOF'
    #!/bin/bash
    echo "=== BGP Summary ==="
    sudo vtysh -c "show bgp summary"
    echo ""
    echo "=== BGP Neighbors ==="
    sudo vtysh -c "show bgp neighbors"
    echo ""
    echo "=== BGP Routes ==="
    sudo vtysh -c "show bgp"
    BGP_STATUS_EOF
    
  - chmod +x /home/admin-lab/bgp-status.sh
  - chown admin-lab:admin-lab /home/admin-lab/bgp-status.sh

# Final message
final_message: |
  EVP Router ${VM_NAME} setup complete!
  
  BGP Configuration:
  - AS Number: ${ASN}
  - Router ID: ${ROUTER_ID}
  - Remote Peer: ${REMOTE_PEER_IP} (AS 65000)
  
  Useful commands:
  - sudo vtysh (enter FRR shell)
  - ./bgp-status.sh (check BGP status)
  - sudo systemctl status frr
  
  Login credentials:
  - Username: admin-lab
  - Password: ubuntu
EOF

# Create cloud-init meta-data
cat > "/tmp/${VM_NAME}-meta-data" << EOF
instance-id: ${VM_NAME}
local-hostname: ${VM_NAME}
EOF

# Create cloud-init ISO
echo "Creating cloud-init ISO..."
genisoimage -output "$CLOUD_INIT_ISO" -volid cidata -joliet -rock "/tmp/${VM_NAME}-user-data" "/tmp/${VM_NAME}-meta-data"

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
    --disk path="$AVIATRIX_ISO",device=cdrom,bus=sata,readonly=on \
    --disk path="$CLOUD_INIT_ISO",device=cdrom,bus=sata,readonly=on \
    --network network=lan,model=virtio \
    --graphics vnc,listen=0.0.0.0,port=-1 \
    --console pty,target_type=serial \
    --boot hd,cdrom \
    --os-variant="$OS_TYPE" \
    --noautoconsole \
    --autostart

echo ""
echo "VM '$VM_NAME' created and started successfully!"
echo ""
echo "VM Details:"
echo "  Name: $VM_NAME"
echo "  Site: $SITE"
echo "  Memory: ${VM_MEMORY} MB"
echo "  vCPUs: $VM_VCPUS"
echo "  Disk: $VM_DISK"
echo "  Network: LAN (virtio)"
echo "  BGP ASN: $ASN"
echo "  BGP Peer: $REMOTE_PEER_IP"
echo "  Router ID: $ROUTER_ID"
echo "  Ubuntu ISO: $ISO_PATH"
echo "  Aviatrix ISO: $AVIATRIX_ISO"
echo ""
echo "The VM will boot from Ubuntu ISO and configure itself via cloud-init."
echo "FRR BGP will be automatically configured and started."
echo ""
echo "Access via VNC console or wait for network configuration to complete."
echo "Default login: admin-lab/ubuntu"

# Clean up temporary files
rm -f "/tmp/${VM_NAME}-user-data" "/tmp/${VM_NAME}-meta-data"

echo ""
echo "Useful commands:"
echo "  virsh start $VM_NAME      # Start VM"
echo "  virsh shutdown $VM_NAME   # Shutdown VM"
echo "  virsh console $VM_NAME    # Connect to console"
echo "  virsh vncdisplay $VM_NAME # Get VNC display"