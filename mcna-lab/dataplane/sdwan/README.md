# SDWAN integration with Aviatrix Transit in Azure

## Transit side
 - Uses an external BGP over LAN connection
 - Transit vnet is peered to sdwan vnet
 - Transit is located in the dataplane terraform and data are retrieve using TF remote state (tfe_outputs)

## SDWAN side
 - Contains a VM acting as an FRR router with IP Forwarding enabled on Azure and on Linux
 - UDR is applied to send traffic back to Aviatrix transit for RFC1918 (Azure specific)

## SDWAN Tiered spoke 
 - Contains a test VM acting as an SDWAN branches

## Datapath

test VM in dataplace -> Aviatrix Spoke -> Aviatrix WE transit -> vnet peering -> SDWAN VM -> vnet peering -> tiered spoke -> tiered test VM