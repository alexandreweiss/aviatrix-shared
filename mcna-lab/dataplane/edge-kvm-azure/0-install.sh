#/bin/sh

sudo apt-get update -y
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager -y
sudo kvm-ok
sudo usermod -aG libvirt $USER
sudo systemctl enable --now libvirtd
sudo apt install cockpit -y
sudo apt install cockpit-machines -y


# To be added to 
# /etc/apparmor.d/usr.sbin.libvirtd

# specific path
#   /virtu/** rwk,

# Reload profile
# sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.libvirtd

# Restart daemon
# sudo systemctl restart libvirtd