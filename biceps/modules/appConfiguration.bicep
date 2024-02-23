@description('Specifies the name of the App Configuration store.')
param configStoreName string

@description('Specifies the Azure location where the app configuration store should be created.')
param location string = resourceGroup().location

resource configStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: configStoreName
  location: location
  sku: {
    name: 'free'
  }
}

var readonlyKey = filter(configStore.listKeys().value, k => k.name == 'Primary Read Only')[0]
output connectionString string = readonlyKey.connectionString
