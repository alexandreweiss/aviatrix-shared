#!/usr/bin/env bash
set -euo pipefail

# Source the config file if it exists
if [[ -f /tmp/config.env ]]; then
    source /tmp/config.env
else
    echo "Error: Config file /tmp/config.env not found"
    exit 1
fi

echo "Creating KVM virtual networks..."

# Create WAN network
cat > /tmp/wan-network.xml << EOF
<network>
  <name>wan</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr1' stp='on' delay='0'/>
  <ip address='172.22.${WORKSPACE_ID}.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='172.22.${WORKSPACE_ID}.10' end='172.22.${WORKSPACE_ID}.20'/>
    </dhcp>
  </ip>
</network>
EOF

# Create LAN network
cat > /tmp/lan-network.xml << EOF
<network>
  <name>lan</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr2' stp='on' delay='0'/>
  <ip address='172.22.$((WORKSPACE_ID + 1)).1' netmask='255.255.255.0'>
    <dhcp>
      <range start='172.22.$((WORKSPACE_ID + 1)).10' end='172.22.$((WORKSPACE_ID + 1)).20'/>
    </dhcp>
  </ip>
</network>
EOF

# Create MGMT network
cat > /tmp/mgmt-network.xml << EOF
<network>
  <name>mgmt</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr3' stp='on' delay='0'/>
  <ip address='172.22.$((WORKSPACE_ID + 2)).1' netmask='255.255.255.0'>
    <dhcp>
      <range start='172.22.$((WORKSPACE_ID + 2)).10' end='172.22.$((WORKSPACE_ID + 2)).20'/>
    </dhcp>
  </ip>
</network>
EOF

# Define and start networks
networks=("wan" "lan" "mgmt")

for network in "${networks[@]}"
do
  echo "Creating network: $network"
  virsh net-define /tmp/${network}-network.xml
  virsh net-start $network
  virsh net-autostart $network
  echo "Network $network created and started successfully"
done

# Show created networks
echo "Created virtual networks:"
virsh net-list --all

# Clean up XML files
rm -f /tmp/*-network.xml

echo "KVM virtual networks setup completed"