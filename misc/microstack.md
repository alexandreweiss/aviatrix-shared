# Cloud init updates

## Decode what's needed from metadata
cat metadata.json | base64 -d | gunzip > metadata-decoded.json
## Encode as needed
cat metadata-decoded.json | gzip | base64 > metadata.json

## Add this to prevent microstack to configure network
#cloud-config
network:
  config: disabled

## Install virsh on host
sudo apt install virtinst libvirt-clients libvirt-daemon-system

# List instances from the host SSH connection
sudo virsh --connect qemu+unix:///system?socket=/var/snap/microstack/common/run/libvirt/libvirt-sock list --all

# Connect console to the instances
sudo virsh --connect qemu+unix:///system?socket=/var/snap/microstack/common/run/libvirt/libvirt-sock console instance-0000001a

# Create bindings as a service

sudo tee /usr/local/sbin/microstack-ovn-bridge-mappings.sh <<'EOF'
  #!/bin/bash
  set -e
  microstack.ovs-vsctl set open . external-ids:ovn-bridge-mappings=\
  physnet1:br-ex,\
  physnet-wan:br-wan,\
  physnet-mgmt:br-mgmt
  EOF
sudo chmod +x /usr/local/sbin/microstack-ovn-bridge-mappings.sh
sudo tee /etc/systemd/system/microstack-ovn-bridge-mappings.service <<'EOF'
  [Unit]
  Description=Restore MicroStack OVN bridge mappings
  After=snap.microstack.ovs-vswitchd.service
  Requires=snap.microstack.ovs-vswitchd.service
  [Service]
  Type=oneshot
  ExecStart=/usr/local/sbin/microstack-ovn-bridge-mappings.sh
  RemainAfterExit=yes
  [Install]
  WantedBy=multi-user.target
  EOF
sudo systemctl daemon-reload
sudo systemctl enable microstack-ovn-bridge-mappings

## List bridges
sudo microstack.ovs-vsctl get open . external-ids:ovn-bridge-mappings

# create instance

## Create network
sudo microstack.openstack network create   --share   --provider-physical-network physnet-wan --provider-network-type flat sites-wan
sudo microstack.openstack network create   --share   --provider-physical-network physnet-wan2 --provider-network-type flat sites-wan2
sudo microstack.openstack network create   --share   --provider-physical-network physnet-mgmt --provider-network-type flat sites-mgmt

## Create subnet

## Create port
sudo microstack.openstack port create   --network sites-wan   --disable-port-security  edge-ms-wan
sudo microstack.openstack port create   --network sites-mgmt   --disable-port-security  edge-ms-mgmt

Creation of additional ports :
sudo microstack.openstack port create   --network sites-mgmt   --disable-port-security  ob-eat-0-mgmt
etc ...

## Create instance
microstack.openstack image list
IMAGE_ID=95ca0660-9ad1-445c-bc9c-221bffef25bf
sudo microstack.openstack server create   --flavor m1.medium   --image $IMAGE_ID   --nic port-id=$(sudo microstack.openstack port show edge-ms-wan -f value -c id)   --nic port-id=$(sudo microstack.openstack port show edge-ms-lan -f value -c id)   --nic port-id=$(sudo microstack.openstack port show edge-ms-mgmt -f value -c id)   --config-drive true   --user-data /var/snap/microstack/common/edge-user-data.txt   edgems-0


admin-lab@microstack:~$ ms port list
+--------------------------------------+--------------+-------------------+------------------------------------------------------------------------------+--------+
| ID                                   | Name         | MAC Address       | Fixed IP Addresses                                                           | Status |
+--------------------------------------+--------------+-------------------+------------------------------------------------------------------------------+--------+
| 12453a3a-b901-4a0f-bd4b-205e0b81d165 |              | fa:16:3e:f9:38:ce | ip_address='10.20.20.76', subnet_id='faffb3f1-a485-4684-a50b-5250c035d267'   | ACTIVE |
| 299deb22-c94b-4440-b748-21e6028de5dc | edge-ms-wan  | fa:16:3e:21:fd:dc | ip_address='10.89.0.130', subnet_id='35ae1bd5-0da7-4b70-842c-60c06882689c'   | ACTIVE |
| 30bd32a9-0e18-4406-9796-ebe8e84dd1d3 | edge-ms-mgmt | fa:16:3e:e6:28:2d | ip_address='10.88.0.128', subnet_id='4e0ae07d-2ed3-44d4-bdd4-8001775d6950'   | ACTIVE |
| 4ff72ecc-24ab-4475-802a-27172b0d8921 | edge-ms-lan  | fa:16:3e:07:fe:9f | ip_address='10.10.10.204', subnet_id='1aa3c0a9-2410-4b9f-87a7-584d288e932c'  | ACTIVE |
| ba58536c-e04c-4f25-ba0a-f7334832945d |              | fa:16:3e:93:70:5a | ip_address='192.168.222.1', subnet_id='a528395c-6a64-4664-9299-2ac2525e23b7' | ACTIVE |

# Example after reboot
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 2602:f5af::9/128 scope global 
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether fa:16:3e:21:fd:dc brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    altname ens3
    inet 10.89.0.20/24 brd 10.89.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1442 qdisc fq_codel state UP group default qlen 1000
    link/ether fa:16:3e:07:fe:9f brd ff:ff:ff:ff:ff:ff
    altname enp0s4
    altname ens4
    inet 10.10.10.20/24 brd 10.10.10.255 scope global eth1
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether fa:16:3e:e6:28:2d brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    altname ens5
    inet 10.88.0.14/24 brd 10.88.0.255 scope global eth2
       valid_lft forever preferred_lft forever
5: ids0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 9001 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether 22:bc:48:39:2f:5f brd ff:ff:ff:ff:ff:ff
    inet6 fe80::20bc:48ff:fe39:2f5f/64 scope link 
       valid_lft forever preferred_lft forever


# Run nginx pod for HA
sudo podman run -d --network vlan50 --ip 192.168.50.161 --dns 192.168.50.1 -v nginx-certs:/etc/letsencrypt --name nginx-dmz nginx-dmz