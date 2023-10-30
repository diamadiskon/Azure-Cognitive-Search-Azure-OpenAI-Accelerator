// Parameters
@description('Location of the resources.')
param location string

@description('Name of the blob storage account.')
param blobStorageAccountName string

@description('ID of the subnet where the private endpoint should be placed.')
param subnet_id string

@description('Private dns zone  name.')
param private_dns_zone_name string

@description('ID of the virtual network to which the private dns zone will be linked')
param vnet_id string

@description('Name of the private endpoint.')
param privateEndpointName string = 'pe-${blobStorageAccountName}'

// Resources
resource blobStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: blobStorageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: blobStorageAccount
  name: 'default'
}

resource blobStorageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for containerName in [ 'books', 'cord19', 'mixed' ]: {
  parent: blobServices
  name: containerName
}]

resource blobStoragePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet_id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: blobStorageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: private_dns_zone_name
  location: 'global'
  // properties: {
  //   privateZoneNameConfigurations: [
  //     {
  //       name: 'blob'
  //       privateZoneName: 'blob.core.windows.net'
  //     }
  //   ]
  // }
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${private_dns_zone_name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet_id
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointName}-privateDnsZoneGroup'
  parent: blobStoragePrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${privateEndpointName}-privateDnsZoneConfig'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
