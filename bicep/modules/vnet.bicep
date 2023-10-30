// Virtual network with three subnets

@description('Name of the vnet')
param vnetName string

@description('Location of vnet')
param location string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'snet-frontend' // subnet for frontend resources
        properties: {
          addressPrefix: '10.1.0.0/25'
          privateEndpointNetworkPolicies: 'Disabled'
          delegations: [
            {
              name: 'Microsoft.Web.serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'snet-backend' // subnet for backend resources 
        properties: {
          addressPrefix: '10.1.0.128/26'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          delegations: [
            {
              name: 'Microsoft.Web.serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }

      {
        name: 'snet-private' // subnet for private endpoints 
        properties: {
          addressPrefix: '10.1.0.224/27'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }

    ]
  }
}

output vnetName string = virtualNetwork.name
output vnetId string = virtualNetwork.id
output frontendSubnetId string = virtualNetwork.properties.subnets[0].id
output backendSubnetId string = virtualNetwork.properties.subnets[1].id
output privateSubnetId string = virtualNetwork.properties.subnets[2].id
