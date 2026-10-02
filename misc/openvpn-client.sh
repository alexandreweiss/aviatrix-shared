# This script is intended to start an OpenVPN session using the OpenVPN 3 Linux client with a specific configuration named "foundry". It initiates the VPN connection based on the provided configuration file.
openvpn3 session-start --config foundry

# The following command imports an OpenVPN configuration file into the OpenVPN 3 Linux client. It specifies the configuration file path and assigns it a name "foundry" for easier reference in future commands.
openvpn3 config-import --config foundry-user-647403-vnet-foundry-647403_foundry-sec-network-rg-647403_61e2a827-9db4-4e7c-beee-a5403e524828-0x4e9725f.ovpn --name foundry

# This script is designed to manage OpenVPN client configurations using the OpenVPN 3 Linux client. It provides commands to list existing configurations, show details of a specific configuration, and remove a configuration if necessary.
openvpn3 configs-list

# This script is used to manage OpenVPN client configurations. It allows you to view the current configuration for a specific profile named "foundry" and enables asymmetric compression if needed.
openvpn3 config-manage --show --config foundry --allow-compression asym

# The following command removes the OpenVPN configuration for the specified path. This is useful for cleaning up or resetting configurations that are no longer needed.
openvpn3 config-remove --path /net/openvpn/v3/configuration/9691255fx7e42x42b6x9216xf6e58c1f6987