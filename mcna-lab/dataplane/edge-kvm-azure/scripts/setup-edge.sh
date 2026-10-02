#!/usr/bin/env bash
set -euo pipefail

echo "Downloading Aviatrix Edge Gateway image..."
cd /tmp
wget https://cdn.sre.aviatrix.com/edge-platform/g4-202507291722/avx-gateway-g4-202507291722.qcow2

echo "Resizing image..."
qemu-img resize avx-gateway-g4-202507291722.qcow2 +10G

echo "Moving image to storage location..."
mv avx-gateway-g4-202507291722.qcow2 /virtu/iso/
chown libvirt-qemu:kvm /virtu/iso/avx-gateway-g4-202507291722.qcow2

echo "Downloading Ubuntu 24.04.3 Server ISO..."
cd /virtu/iso
wget https://releases.ubuntu.com/24.04.3/ubuntu-24.04.3-live-server-amd64.iso
chown libvirt-qemu:kvm /virtu/iso/ubuntu-24.04.3-live-server-amd64.iso

echo "Edge Gateway image and Ubuntu ISO setup completed"