targetScope = 'subscription'

/// Parameters ///

@description('ID of the subscription')
param subscription_id string = '4b3e8c6e-448a-4a6c-9c1d-106719e46a65'

@description('Azure region used for the deployment of all resources')
param location string = 'westeurope'

@description('Abbreviation fo the location')
param location_abbreviation string = 'weu'

@description('Name of the workload that will be deployed')
param workload string = 'webapp'

param environment string = 'dev'

@description('name of the resource group where the workload will be deployed')
param rg_name string

param rg_tags object = {}

@description('SQL Server Name')
param SQLServerName string = 'sql-${workload}-${environment}-${location_abbreviation}'

@description('SQL Server Database Name')
param SQLServerDatabase string = 'db-${workload}-${environment}-${location_abbreviation}'

@description('SQL Server Username')
param SQLServerUsername string = 'sqladmin'

@secure()
param SQLServerPassword string = ''

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

var tags = union({
    workload: workload
    environment: environment
  }, rg_tags)

/// Resources ///

// resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
//   name: 'rg-${workload}-${environment}-${location_abbreviation}'
//   location: location
//   tags: tags
// }

/// Modules ///

module network 'modules/vnet.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'network-${workload}-deployment'
  params: {
    vnetName: 'vnet-${workload}-${environment}-${location_abbreviation}'
    location: location
  }
}

module frontend 'modules/frontend.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'frontend-${workload}-deployment'
  params: {
    // azureOpenAIAPIKey: azureOpenAIAPIKey
    // azureOpenAIName: azureOpenAIName
    // azureSearchName: azureSearchName
    // blobSASToken: blobSASToken
    // botDirectLineChannelKey: botDirectLineChannelKey
    // botServiceName: botServiceName
    subnet_id: network.outputs.frontendSubnetId
    location: location
  }
}

module backend 'modules/backend.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'backend-${workload}-deployment'
  params: {
    SQLServerName: SQLServerName
    SQLServerDatabase: SQLServerDatabase
    SQLServerUsername: SQLServerUsername
    SQLServerPassword: SQLServerPassword
    location: location
    subnet_id: network.outputs.backendSubnetId
  }

}

module sql 'modules/sql.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'sql-${workload}-deployment'
  params: {
    subnet_id: network.outputs.privateSubnetId
  }
}
