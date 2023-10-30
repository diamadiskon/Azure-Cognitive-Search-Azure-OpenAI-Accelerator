@description('Location of the resource.')
param location string

@description('Name of the Cosmos DB account.')
param cosmosDBAccountName string

@description('ID of the subnet to which the private endpoint will be linked')
param subnet_id string

@description('Name of the Cosmos DB database.')
param cosmosDBDatabaseName string

@description('Name of the Cosmos DB container.')
param cosmosDBContainerName string

@description('ID of the virtual network to which the private dns zone will be linked')
param vnet_id string

@description('Name of SQL Server private endpoint.')
param privateEndpointName string = 'pe-${cosmosDBAccountName}'

@description('Private DNS Zone Name.')
param private_dns_zone_name string = 'privatelink.documents.azure.com'

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDBAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
    enableFreeTier: false
    isVirtualNetworkFilterEnabled: false
    publicNetworkAccess: 'Disabled'
  }
}

resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosDBAccount
  name: cosmosDBDatabaseName
  location: location
  properties: {
    resource: {
      id: cosmosDBDatabaseName
    }
  }
}

resource cosmosDBContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDBDatabase
  name: cosmosDBContainerName
  location: location
  properties: {
    resource: {
      id: cosmosDBContainerName
      partitionKey: {
        paths: [
          '/user_id'
        ]
        kind: 'Hash'
        version: 2
      }
      defaultTtl: 1000
    }
  }
}

resource cosmosDBPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
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
          privateLinkServiceId: cosmosDBAccount.id
          groupIds: [
            'Sql'
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: private_dns_zone_name
  location: 'global'
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
  parent: cosmosDBPrivateEndpoint
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
