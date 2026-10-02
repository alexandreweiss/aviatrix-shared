# ARS LAB

## Aviatrix transit vnet
An Aviatrix transit is deployed as HA in its own vnet
ARS is peered to ARS over vnet peering using BGPoLAN

## ARS and FWs
ARS is deployed in its own vnet along with two firewalls (linux VMs). Both firewalls seating being an ILB.
FWs are running FRR and are peered to ARS.

## Spoke
A test VM in a spoke peered to ARS vnet to simulate workload.

## Spoke on Aviatrix side (no deployed by that code)
We use an existing spoke containing a test VM attached to Aviatrix transit

# Goal
We demonstrate that traffic passes :
- From VM in the Aviatrix spoke
- To Aviatrix Transit
- To ARS
- To ILB
- To FWs
- To workload in the spoke vnet peered to ARS vnet.