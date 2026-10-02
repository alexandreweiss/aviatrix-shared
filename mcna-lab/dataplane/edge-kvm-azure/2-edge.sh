sudo wget https://cdn.sre.aviatrix.com/edge-platform/g4-202507291722/avx-gateway-g4-202507291722.qcow2

sudo qemu-img resize avx-gateway-g4-202507291722.qcow2 +10G

sudo mv avx-gateway-g4-202507291722.qcow2 /virtu/iso
sudo chown libvirt-qemu:kvm avx-gateway-g4-202507291722.qcow2