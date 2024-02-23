// param isGeoReplicated bool = false
param uniqPrefix string
param databaseSKU object = {
  name: 'Basic'
  tier: 'Basic'
  capacity: 50
}
param databaseHangfireSKU object = {
  name: 'Basic'
  tier: 'Basic'
  capacity: 50
}


@description('Location for all resources.')
param location string = resourceGroup().location

var sqlServerName = '${uniqPrefix}-server'
var sqlDbName = '${uniqPrefix}-db'
var login = '${uniqPrefix}-sqluser'
var password = guid(uniqPrefix)

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: login
    administratorLoginPassword: password
  }
}

resource sqlAdmin 'Microsoft.Sql/servers/administrators@2022-05-01-preview' = {
  name: 'ActiveDirectory'
  parent: sqlServer
  properties: {
    administratorType: 'ActiveDirectory'
    login: 'admin@user.com'
    sid: '<sid-of-admin-user>'
    tenantId: '<tenant-id>'
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  parent: sqlServer
  name: sqlDbName
  location: location
  sku: databaseSKU
  tags: {
    ContainsUserData: 'true'
  }
}

resource sqlDBHangfire 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  parent: sqlServer
  name: '${sqlDbName}-hangfire'
  location: location
  sku: databaseHangfireSKU
}

resource shortTermBackupPolicy 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2022-05-01-preview' = {
  name: 'default'
  parent: sqlDB
  properties: {
    diffBackupIntervalInHours: 12
    retentionDays: 14
  }
}

resource longTermBackupPolicy 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2022-05-01-preview' = {
  name: 'default'
  parent: sqlDB
  properties: {
    // monthlyRetention: 'string'
    weeklyRetention: 'P24W'
    // weekOfYear: 1
    // yearlyRetention: 'string'
  }
}

// resource sqlServerReplica 'Microsoft.Sql/servers@2022-02-01-preview' = if (isGeoReplicated) {
//   name: '${sqlServerName}-replica'
//   location: (location == 'westeurope') ? 'northeurope' : location
//   properties: {
//     administratorLogin: login
//     administratorLoginPassword: password
//   }
// }

// resource sqlDBReplica 'Microsoft.Sql/servers/databases@2022-02-01-preview' = if (isGeoReplicated) {
//   parent: sqlServerReplica
//   name: sqlDBName
//   location: (location == 'westeurope') ? 'northeurope' : location
//   sku: {
//     name: 'Standard'
//     tier: 'Standard'
//     capacity: 50
//   }
//   properties: {
//     createMode: 'OnlineSecondary'
//     sourceDatabaseId: sqlDB.id
//     secondaryType: 'Geo'
//   }
//   dependsOn: [
//     sqlServer
//   ]
// }

//this is needed for azure services to access the database
resource SQLAllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2022-08-01-preview' = {
  name: 'AllowAllWindowsAzureIps'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

var connectionString = 'Server=${sqlServer.properties.fullyQualifiedDomainName};Database=${sqlDbName};User Id=${login};Password=${password};'
var hangfireConnectionString = 'Server=${sqlServer.properties.fullyQualifiedDomainName};Database=${sqlDbName}-hangfire;User Id=${login};Password=${password};'

output sqlConnectionString string = connectionString
output hangfireConnectionString string = hangfireConnectionString

output sqlServerName string = sqlServerName
output sqlDbName string = sqlDbName
