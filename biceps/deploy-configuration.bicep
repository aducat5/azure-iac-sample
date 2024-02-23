targetScope = 'resourceGroup'

param defaultLocation string = resourceGroup().location

var rg = resourceGroup()
var uniqAppName = toLower('shared-${uniqueString(rg.id)}')
var configStoreName = '${uniqAppName}-appConfiguration'

module configurationStore 'modules/appConfiguration.bicep' = {
  name: configStoreName
  params: {
    configStoreName: configStoreName
    location: defaultLocation
  }
}

output configStoreName string = configStoreName
output configStoreConnectionString string = configurationStore.outputs.connectionString
