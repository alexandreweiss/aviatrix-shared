param location string = 'westeurope'

resource nginx 'Nginx.NginxPlus/nginxDeployments@2022-08-01' = {
  name: 'nginx-lab'
   location: location
   properties: {
     networkProfile: {
       frontEndIPConfiguration: {
         privateIPAddresses: [
           {
             subnetId: vnet.outputs.subnets[0].id
              privateIPAddress: '10.0.0.10'
               privateIPAllocationMethod: 'Static'
           }
         ]
       }
        networkInterfaceConfiguration: {
           subnetId: vnet.outputs.subnets[0].id
        }
     }

   }
   sku: {
    name: 'publicpreview_Monthly_gmz7xq9ge3py'
   }
}

module vnet '../_modules/vnetMultiSubnets.bicep' = {
  name: 'nginx-vnet'
  params: {
    addressSpace: '10.0.0.0/24'
    location: location
    subnets: [
      {
        name: 'default'
        addressPrefix: '10.0.0.0/28'
        delegations: [
          {
            name: 'NGINX.NGINXPLUS/nginxDeployments'
            properties: {
              serviceName:'NGINX.NGINXPLUS/nginxDeployments'
            }
          }
        ]

      }
    ]
    vnetName: 'nginx-vnet'
  }
}
