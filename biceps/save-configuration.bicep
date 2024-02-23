targetScope = 'resourceGroup'

param tenant string
param configStoreName string
param sqlConnection string
param hangfireConnection string
param storageConnection string


var runtimeKeys = [
  'Configuration:Database$${tenant}'
  'Configuration:DatabaseHangfire$${tenant}'
  'Configuration:StorageConnString$${tenant}'
]

var runtimeValues = [
  sqlConnection
  hangfireConnection
  storageConnection
]

//save runtime configuration
resource configStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' existing = {
  name: configStoreName
}

resource configStoreKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = [for (item, i) in runtimeKeys: {
  parent: configStore
  name: item
  properties: {
    value: runtimeValues[i]
  }
}]
