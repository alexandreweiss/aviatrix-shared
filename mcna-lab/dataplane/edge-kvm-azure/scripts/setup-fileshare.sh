#!/usr/bin/env bash
set -euo pipefail

# Source the config file if it exists
if [[ -f /tmp/config.env ]]; then
    source /tmp/config.env
else
    echo "Error: Config file /tmp/config.env not found"
    exit 1
fi

echo "Setting up Azure File Share..."

# Create mount point
mkdir -p /mnt/edge-isos

echo "File share mount point created at /mnt/edge-isos"

# Mount the Azure File Share automatically
echo "Mounting Azure File Share..."
sudo mount -t cifs //${STORAGE_ACCOUNT_NAME}.file.core.windows.net/edge-isos /mnt/edge-isos \
    -o vers=3.0,username=${STORAGE_ACCOUNT_NAME},password=${STORAGE_ACCOUNT_KEY},dir_mode=0777,file_mode=0777,serverino

if [ $? -eq 0 ]; then
  echo "Azure File Share mounted successfully at /mnt/edge-isos"
  # Add to fstab for persistent mounting
  echo "//${STORAGE_ACCOUNT_NAME}.file.core.windows.net/edge-isos /mnt/edge-isos cifs vers=3.0,username=${STORAGE_ACCOUNT_NAME},password=${STORAGE_ACCOUNT_KEY},dir_mode=0777,file_mode=0777,serverino,nofail 0 0" >> /etc/fstab
else
  echo "Failed to mount Azure File Share"
fi

# Create a helper script for manual mounting/unmounting
cat > /home/admin-lab/mount-fileshare.sh << 'MOUNT_EOF'
#!/bin/bash
# Azure File Share Mount Helper (for manual remounting if needed)
# Usage: ./mount-fileshare.sh <storage-account-name> <storage-account-key>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <storage-account-name> <storage-account-key>"
    echo "Example: $0 edgekvmsa$WORKSPACE $STORAGE_KEY"
    exit 1
fi

STORAGE_ACCOUNT="$1"
STORAGE_KEY="$2"

sudo mount -t cifs //${STORAGE_ACCOUNT}.file.core.windows.net/edge-isos /mnt/edge-isos \
    -o vers=3.0,username=${STORAGE_ACCOUNT},password=${STORAGE_KEY},dir_mode=0777,file_mode=0777,serverino

echo "File share mounted at /mnt/edge-isos"
MOUNT_EOF

chmod +x /home/admin-lab/mount-fileshare.sh
chown admin-lab:admin-lab /home/admin-lab/mount-fileshare.sh

echo "Azure File Share setup and mounting completed"