targetScope = 'resourceGroup'

param appName string
param defaultLocation string

var rg = resourceGroup()
var uniqAppName = toLower('${appName}-${uniqueString(rg.id)}')
var configStoreName = '${uniqAppName}-appConfiguration'

module configurationStore 'modules/appConfiguration.bicep' = {
  name: configStoreName
  params: {
    configStoreName: configStoreName
    location: defaultLocation
  }
}

output csName string = configStoreName

// var listKeysResult = listKeys(configurationStore.outputs.endpoint.value, '2019-10-01')

// output appConfigurationAccessKey string = listKeysResult.primary.value


