#!/usr/bin/env bash
set -euo pipefail

DISK="/dev/nvme0n2"
PART="${DISK}p1"
MOUNTPOINT="/virtu"
FS_TYPE="ext4"
FSTAB="/etc/fstab"

CONFIRM=false

usage() {
  cat <<EOF
Usage: $0 [--force]

Initialize ${DISK}, create a single ${FS_TYPE} partition, mount it at ${MOUNTPOINT},
and add a persistent /etc/fstab entry.

Options:
  --force   Proceed without confirmation even if the disk/partition has data.
  -h, --help Show this help.

Notes:
  - This will create a GPT label and a single primary partition consuming 100% of the disk.
  - Formatting will ERASE existing data on ${PART}.
EOF
}

# Parse args
while [[ ${1:-} ]]; do
  case "$1" in
    --force) CONFIRM=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# Root check
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo)."
  exit 1
fi

# Validate disk exists
if [[ ! -b "$DISK" ]]; then
  echo "Disk $DISK not found. Aborting."
  exit 1
fi

echo "Target disk: $DISK"
echo "Target partition: $PART"
echo "Mount point: $MOUNTPOINT"

# Ensure mount point exists
mkdir -p "$MOUNTPOINT"

# Check if already mounted
if mount | grep -qE "on ${MOUNTPOINT} "; then
  echo "$MOUNTPOINT already mounted. Skipping partition/format."
  df -h | grep -E "${MOUNTPOINT}\$" || true
  exit 0
fi

# Check existing partitions
EXISTING_PARTS=$(lsblk -no NAME "${DISK}" | grep -E "^nvme0n2p[0-9]+" || true)
if [[ -n "$EXISTING_PARTS" ]]; then
  echo "Found existing partitions on ${DISK}:"
  lsblk "${DISK}"
  if [[ "$CONFIRM" == false ]]; then
    read -r -p "Proceed and (re)use ${PART}? This may erase data. [y/N]: " ans
    ans=${ans:-N}
    if [[ ! "$ans" =~ ^[Yy]$ ]]; then
      echo "Aborting."
      exit 1
    fi
  fi
fi

# Create partition if ${PART} does not exist
if [[ ! -b "$PART" ]]; then
  echo "Creating GPT and primary partition on ${DISK}..."
  # Wipe existing signatures cautiously
  wipefs -f -a "$DISK" || true

  # Create GPT + single partition full disk
  parted -s "$DISK" mklabel gpt
  parted -s "$DISK" mkpart primary "${FS_TYPE}" 0% 100%

  # Wait for kernel to notice partition
  partprobe "$DISK" || true
  udevadm settle || true

  # Verify partition appeared
  if [[ ! -b "$PART" ]]; then
    echo "Partition ${PART} not found after creation. Aborting."
    exit 1
  fi
else
  echo "Partition ${PART} already exists. Reusing."
fi

# Determine if partition already has a filesystem
EXISTING_FS=$(blkid -s TYPE -o value "$PART" || true)
if [[ -n "$EXISTING_FS" && "$EXISTING_FS" != "$FS_TYPE" ]]; then
  echo "Partition has existing filesystem: $EXISTING_FS"
  if [[ "$CONFIRM" == false ]]; then
    read -r -p "Reformat ${PART} to ${FS_TYPE}? This ERASES data. [y/N]: " ans
    ans=${ans:-N}
    if [[ ! "$ans" =~ ^[Yy]$ ]]; then
      echo "Skipping format. Will attempt to mount existing FS."
      FS_TYPE="$EXISTING_FS"
    fi
  else
    echo "Forcing reformat to ${FS_TYPE}."
    mkfs.${FS_TYPE} -F "$PART"
  fi
fi

# If there is no filesystem, format it
if [[ -z "$EXISTING_FS" || "$EXISTING_FS" == "" ]]; then
  echo "Formatting ${PART} as ${FS_TYPE}..."
  mkfs.${FS_TYPE} -F "$PART"
fi

# Get UUID
UUID=$(blkid -s UUID -o value "$PART")
if [[ -z "$UUID" ]]; then
  echo "Failed to retrieve UUID for ${PART}. Aborting."
  exit 1
fi
echo "Partition UUID: $UUID"

# Create fstab entry if missing
FSTAB_LINE="UUID=${UUID} ${MOUNTPOINT} ${FS_TYPE} defaults,nofail 0 2"

if grep -q "$UUID" "$FSTAB"; then
  echo "An /etc/fstab entry for UUID ${UUID} already exists. Skipping fstab update."
else
  echo "Adding entry to /etc/fstab:"
  echo "$FSTAB_LINE"
  echo "$FSTAB_LINE" >> "$FSTAB"
  fi

# Mount
echo "Mounting ${PART} to ${MOUNTPOINT}..."
mount "$MOUNTPOINT"

# Verify
echo "Mounted volumes:"
df -h | grep -E "${MOUNTPOINT}\$" || true

# Change ownership
echo "Chown ..."
sudo chown libvirt-qemu:kvm ${MOUNTPOINT}
sudo chmod 755 ${MOUNTPOINT}

# Create dirs
echo "Creating dirs"
sudo mkdir ${MOUNTPOINT}/vm
sudo mkdir ${MOUNTPOINT}/iso