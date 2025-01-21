# Deploy a Ubuntu Server VM with Standard security mode so that Virtu. Extensions are available
# PAckages
sudo apt-get update -y
sudo apt -y install libvirt-daemon-system bridge-utils qemu-kvm libvirt-daemon cpu-checker cockpit cockpit-{machines,storaged,bridge,packagekit}

# Enable Cockpit autostart
sudo systemctl enable --now cockpit.socket
sudo systemctl start cockpit

# Create user cockpit to login using pwd

sudo useradd cockpit

# Add cockpit user to sudoers file
# WIP

# Init Data disk for VM
sudo parted -s /dev/sda mklabel gpt mkpart primary ext4 0% 100%
sudo mkfs.ext4 /dev/sda1
sudo mkdir -p /mnt/data0

# Retrieve disk ID
UUID=$(sudo blkid -s UUID -o value /dev/sda1)
echo "UUID=$UUID /mnt/data0 ext4 defaults 0 2" | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount -a