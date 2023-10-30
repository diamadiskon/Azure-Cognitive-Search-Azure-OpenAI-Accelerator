targetScope = 'resourceGroup'

/// Parameters ///

@description('Azure region used for the deployment of all resources')
param location string = 'westeurope'

@description('Abbreviation fo the location')
param location_abbreviation string = 'weu'

@description('Name of the workload that will be deployed')
param workload string = 'azure-chatbot'

param environment string = 'dev'

@description('name of the resource group where the workload will be deployed')
param rg_name string

// @description('SQL Server Name')
// param SQLServerName string = 'sql-${workload}-${environment}-${location_abbreviation}'

// @description('SQL Server Database Name')
// param SQLDBName string = 'db-${workload}-${environment}-${location_abbreviation}'

// @description('SQL administrator login')
// param SQLAdministratorLogin string

// @secure()
// @description('SQL administrator login password')
// param SQLAdministratorLoginPassword string

param cosmosDBAccountName string = 'cosmosaccount-${workload}-${environment}-${location_abbreviation}'
param cosmosDBContainerName string = 'cosmoscontainer-${workload}-${environment}-${location_abbreviation}'
param cosmosDBDatabaseName string = 'cosmosdb-${workload}-${environment}-${location_abbreviation}'

// @description('Azure OpenAI API Key')
// param azureOpenAIAPIKey string = ''

// @description('Azure OpenAI Name')
// param azureOpenAIName string = 'openai-${workload}-${environment}-${location_abbreviation}'

// @description('Azure Search Name')
// param azureSearchName string = 'search-${workload}-${environment}-${location_abbreviation}'

// @description('Blob SAS Token')
// param blobSASToken string = ''

// @description('Bot Direct Line Channel Key')
// param botDirectLineChannelKey string = ''

// @description('Bot Service Name')
// param botServiceName string = 'bot-${workload}-${environment}-${location_abbreviation}'

/// Variables ///

/// Modules ///

module network 'modules/vnet.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'network-${workload}-deployment'
  params: {
    location: location
    vnetName: 'vnet-${workload}-${environment}-${location_abbreviation}'
  }
}

// module frontend 'modules/frontend.bicep' = {
//   scope: resourceGroup(rg_name)
//   name: 'frontend-${workload}-deployment'
//   params: {
//     location: location
//     // azureOpenAIAPIKey: azureOpenAIAPIKey
//     // azureOpenAIName: azureOpenAIName
//     // azureSearchName: azureSearchName
//     // blobSASToken: blobSASToken
//     // botDirectLineChannelKey: botDirectLineChannelKey
//     // botServiceName: botServiceName
//     vnet_id: network.outputs.vnetId
//     subnet_id: network.outputs.privateSubnetId
//   }
// }

// module backend 'modules/backend.bicep' = {
//   scope: resourceGroup(rg_name)
//   name: 'backend-${workload}-deployment'
//   params: {
//     location: location
//     SQLServerName: SQLServerName
//     SQLServerDatabase: SQLDBName
//     SQLServerUsername: SQLAdministratorLogin
//     SQLServerPassword: SQLAdministratorLoginPassword
//     vnet_id: network.outputs.vnetId
//     subnet_id: network.outputs.privateSubnetId
//   }
// }

// module sql 'modules/sql.bicep' = {
//   scope: resourceGroup(rg_name)
//   name: 'sql-${workload}-deployment'
//   params: {
//     location: location
//     SQLServerName: SQLServerName
//     SQLAdministratorLogin: SQLAdministratorLogin
//     SQLAdministratorLoginPassword: SQLAdministratorLoginPassword
//     SQLDBName: SQLDBName
//     vnet_id: network.outputs.vnetId
//     subnet_id: network.outputs.privateSubnetId
//   }
// }

module cosmosdb 'modules/cosmosdb.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'cosmosdb-${workload}-deployment'
  params: {
    location: location
    vnet_id: network.outputs.vnetId
    subnet_id: network.outputs.privateSubnetId
    cosmosDBAccountName: cosmosDBAccountName
    cosmosDBContainerName: cosmosDBContainerName
    cosmosDBDatabaseName: cosmosDBDatabaseName
  }
}

module blobStorage 'modules/blobStorage.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'blobStorage-${workload}-deployment'
  params: {
    location: location
    vnet_id: network.outputs.vnetId
    subnet_id: network.outputs.privateSubnetId
    blobStorageAccountName: 'blbstr'
    private_dns_zone_name: 'privatelink.blob.core.windows.net'
  }
}
