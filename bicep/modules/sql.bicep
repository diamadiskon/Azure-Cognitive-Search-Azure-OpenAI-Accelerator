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

@description('Delegated subnet resource id used to setup vnet for a server')
param subnet_id string

@description('ID of the virtual network to which the private dns zone will be linked')
param vnet_id string

// Variables

var private_dns_zone_name = '${SQLServerName}.private.mysql.database.azure.com'

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
    subnetId: subnet_id

    // network: {// https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/2022-11-01-preview/servers#ServerPropertiesForCreateOrUpdate
    //   privateDnsZoneArmResourceId: private_dns_zone.id
    //   privateEndpointConnections: [
    //     {
    //       name: 'private-dns-vnet-link-${SQLServerName}'
    //       properties: {
    //         privateLinkServiceConnectionState: {
    //           status: 'Approved'
    //           description: 'Auto-Approved'
    //         }
    //       }
    //     }
    //   ]
    // }
  } }

resource SQLDatabase 'Microsoft.Sql/servers/databases@2022-11-01-preview' = {
  parent: SQLServer
  name: SQLDBName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  dependsOn: [
    private_dns_zone_vnet_link
  ]
}

resource SQLFirewallRules 'Microsoft.Sql/servers/firewallRules@2022-11-01-preview' = {
  parent: SQLServer
  name: 'AllowAllAzureIPs'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}
