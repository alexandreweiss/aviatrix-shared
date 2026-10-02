#!/usr/bin/env bash
set -euo pipefail

DISK="/dev/nvme0n2"
PART="${DISK}p1"
MOUNTPOINT="/virtu"
FS_TYPE="ext4"
FSTAB="/etc/fstab"

echo "Starting disk setup for ${DISK}"

# Create mount point
mkdir -p "$MOUNTPOINT"

# Check if already mounted
if mount | grep -qE "on ${MOUNTPOINT} "; then
  echo "$MOUNTPOINT already mounted. Skipping."
  exit 0
fi

# Create partition if it doesn't exist
if [[ ! -b "$PART" ]]; then
  echo "Creating GPT and primary partition on ${DISK}..."
  wipefs -f -a "$DISK" || true
  parted -s "$DISK" mklabel gpt
  parted -s "$DISK" mkpart primary "${FS_TYPE}" 0% 100%
  partprobe "$DISK" || true
  udevadm settle || true
fi

# Format if no filesystem exists
EXISTING_FS=$(blkid -s TYPE -o value "$PART" 2>/dev/null || true)
if [[ -z "$EXISTING_FS" ]]; then
  echo "Formatting ${PART} as ${FS_TYPE}..."
  mkfs.${FS_TYPE} -F "$PART"
fi

# Get UUID and add to fstab
UUID=$(blkid -s UUID -o value "$PART")
FSTAB_LINE="UUID=${UUID} ${MOUNTPOINT} ${FS_TYPE} defaults,nofail 0 2"

if ! grep -q "$UUID" "$FSTAB"; then
  echo "$FSTAB_LINE" >> "$FSTAB"
fi

# Mount the partition
mount "$MOUNTPOINT"

# Set ownership and permissions
chown libvirt-qemu:kvm "$MOUNTPOINT"
chmod 755 "$MOUNTPOINT"

# Create required directories
mkdir -p "${MOUNTPOINT}/vm"
mkdir -p "${MOUNTPOINT}/iso"

echo "Disk setup completed successfully"