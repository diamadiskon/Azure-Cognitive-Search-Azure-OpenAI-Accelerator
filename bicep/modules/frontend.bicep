@description('Optional. Web app name must be between 2 and 60 characters.')
@minLength(2)
@maxLength(60)
param webAppName string = 'webApp-gpt-Frontend'

@description('Optional, defaults to S3. The SKU of App Service Plan. The allowed values are B3, S3 and P2v3.')
@allowed([
  'B1'
  'B3'
  'S3'
  'P2v3'
])
param appServicePlanSKU string = 'B1'

@description('Optional. The name of the App Service Plan.')
param appServicePlanName string = 'AppServicePlan-Frontend-${uniqueString(resourceGroup().id)}'

@description('Optional, defaults to resource group location. The location of the resources.')
param location string = resourceGroup().location

@description('Vnet id.')
param vnet_id string

@description('Subnet of the WebApp private endpoint.')
param subnet_id string

param privateEndpointName string = 'pe-${webAppName}'

param private_dns_zone_name string = 'privatelink.azurewebsites.net'

// @description('Required. The name of your Bot Service.')
// param botServiceName string

// @description('Required. The key to the direct line channel of your bot.')
// @secure()
// param botDirectLineChannelKey string

// @description('Required. The SAS token for the Azure Storage Account hosting your data')
// @secure()
// param blobSASToken string

// @description('Optional. The name of the resource group where the resources (Azure Search etc.) where deployed previously. Defaults to current resource group.')
// param resourceGroupSearch string = resourceGroup().name

// @description('Required. The name of the Azure Search service deployed previously.')
// param azureSearchName string

// @description('Optional. The API version of the Azure Search.')
// param azureSearchAPIVersion string = '2023-07-01-Preview'

// @description('Required. The name of the Azure OpenAI resource deployed previously.')
// param azureOpenAIName string

// @description('Required. The API key of the Azure OpenAI resource deployed previously.')
// @secure()
// param azureOpenAIAPIKey string

// @description('Optional. The model name of the Azure OpenAI.')
// param azureOpenAIModelName string = 'gpt-4-32k'

// @description('Optional. The API version of the Azure OpenAI.')
// param azureOpenAIAPIVersion string = '2023-05-15'

// Existing Azure Search service.
// resource azureSearch 'Microsoft.Search/searchServices@2021-04-01-preview' existing = {
//   name: azureSearchName
//   scope: resourceGroup(resourceGroupSearch)
// }

// Create a new Linux App Service Plan.
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSKU
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Create a Web App using a Linux App Service Plan.
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  properties: {
    virtualNetworkSubnetId: subnet_id
    serverFarmId: appServicePlan.id
    publicNetworkAccess: 'Disabled'
    siteConfig: {
      appSettings: [
        // {
        //   name: 'BOT_SERVICE_NAME'
        //   value: botServiceName
        // }
        // {
        //   name: 'BOT_DIRECTLINE_SECRET_KEY'
        //   value: botDirectLineChannelKey
        // }
        // {
        //   name: 'BLOB_SAS_TOKEN'
        //   value: blobSASToken
        // }
        // {
        //   name: 'AZURE_SEARCH_ENDPOINT'
        //   value: 'https://${azureSearchName}.search.windows.net'
        // }
        // {
        //   name: 'AZURE_SEARCH_KEY'
        //   value: azureSearch.listAdminKeys().primaryKey
        // }
        // {
        //   name: 'AZURE_SEARCH_API_VERSION'
        //   value: azureSearchAPIVersion
        // }
        // {
        //   name: 'AZURE_OPENAI_ENDPOINT'
        //   value: 'https://${azureOpenAIName}.openai.azure.com/'
        // }
        // {
        //   name: 'AZURE_OPENAI_API_KEY'
        //   value: azureOpenAIAPIKey
        // }
        // {
        //   name: 'AZURE_OPENAI_MODEL_NAME'
        //   value: azureOpenAIModelName
        // }
        // {
        //   name: 'AZURE_OPENAI_API_VERSION'
        //   value: azureOpenAIAPIVersion
        //}
        // {
        //   name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        //   value: 'true'
        // }
      ]
    }
  }
}


// resource webAppConfig 'Microsoft.Web/sites/config@2022-09-01' = {
//   parent: webApp
//   name: 'web'
//   properties: {
//     linuxFxVersion: 'PYTHON|3.10'
//     alwaysOn: true
//     appCommandLine: 'python -m streamlit run Home.py --server.port 8000 --server.address 0.0.0.0'
//   }
// }


resource BackendPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet_id
    }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-privateLinkServiceConnection'
        properties: {
          privateLinkServiceId: webApp.id
          groupIds: [
            'sites'
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
  parent: BackendPrivateEndpoint
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
