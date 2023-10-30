// Parameters
@description('Location of sql server and database')
param location string

@description('Name of the sql server')
param SQLServerName string

@description('Name of the sql database')
param SQLDBName string

@description('SQL administrator login')
param SQLAdministratorLogin string

@secure()
@description('SQL administrator login password')
param SQLAdministratorLoginPassword string

@description('Subnet id for SQL Private Endpoint')
param subnet_id string

@description('ID of the virtual network to which the private dns zone will be linked')
param vnet_id string

@description('Name of SQL Server private endpoint.')
param privateEndpointName string = 'pe-${SQLServerName}'

@description('Private DNS Zone Name.')
param private_dns_zone_name string = '${SQLServerName}.private.mysql.database.azure.com'

// Resources

resource private_dns_zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: private_dns_zone_name
  location: 'global'
}

resource private_dns_zone_vnet_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: private_dns_zone
  name: 'private-dns-vnet-link-${SQLServerName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet_id
    }
  }
}

resource SQLServer 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: SQLServerName
  location: location
  properties: {
    administratorLogin: SQLAdministratorLogin
    administratorLoginPassword: SQLAdministratorLoginPassword
    publicNetworkAccess: 'Disabled'
    
  } 
}

resource SQLDatabase 'Microsoft.Sql/servers/databases@2022-11-01-preview' = {
  parent: SQLServer
  name: SQLDBName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource SQLFirewallRules 'Microsoft.Sql/servers/firewallRules@2022-11-01-preview' = {
  parent: SQLServer
  name: 'AllowAllAzureIPs'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

// Resources for SQL Server Private Endpoint

resource SQLPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
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
          privateLinkServiceId: SQLServer.id
          groupIds: [
            'sqlServer'
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
  parent: SQLPrivateEndpoint
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
