// Define the parameters for the deployment
param vnetName string = 'myVnet'
param vnetAddressPrefix string = '192.168.0.0/24'
param subnetName string = 'vm'
param subnetPrefix string = '192.168.0.0/28'
param location string = 'westeurope'
param routeTableName string = 'myRouteTable'
param routeName string = 'myRoute'
param routeAddressPrefix string = '192.168.0.0/16'
param routeNextHopIpAddress string = '10.0.0.10'

// Create the virtual network resource
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          // Associate the route table to the subnet
          routeTable: {
            id: routeTable.id
          }
        }
      }
    ]
  }
}

// // Create the route table resource
// resource routeTable 'Microsoft.Network/routeTables@2023-05-01' = {
//   name: routeTableName
//   location: location
//   properties: {
//     disableBgpRoutePropagation: false
//   }
// }

resource routeTable 'Microsoft.Network/routeTables@2022-11-01' = {
  name: routeTableName
  location: location
  properties: {
    disableBgpRoutePropagation: false
  }
}

//Add the route as a child resource outside the route table
resource route 'Microsoft.Network/routeTables/routes@2023-05-01' = {
  name: routeName
  parent: routeTable
  properties: {
    addressPrefix: routeAddressPrefix
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: routeNextHopIpAddress
  }
}

// az group create --location westeurope --resource-group vnet-lab
// az deployment group create --resource-group vnet-lab --template-file vnet.bicep
