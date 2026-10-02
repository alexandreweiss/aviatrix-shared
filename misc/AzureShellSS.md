# Variables
rg="rg-av-AVX-Transit-Firenet-Vnet-185481"
name="we-pa-transit-1-lan-eth2"

# Return nic effective routes


`az network nic show-effective-route-table -n $name --resource-group $rg --output table`

## Sample

---

Source |State|Address Prefix|Next Hop Type|Next Hop IP
--- | --- | --- | --- | ---
Default|Active|10.2.254.0/23|VnetLocal
Default|Invalid|10.2.3.0/24|VNetPeering
Default|Invalid|0.0.0.0/0|Internet
User|Active|0.0.0.0/0|VirtualAppliance|10.2.254.116
User|Active|10.2.1.0/24|VirtualAppliance|10.2.254.116
User|Active|10.2.4.0/24|VirtualApplianc|10.2.254.116
User|Active|10.2.0.0/24|VirtualAppliance|10.2.254.116
User|Active|10.2.3.0/24|VirtualAppliance|10.2.254.116
