param location string = 'West Europe'
param uniqPrefix string
param runtime string
param serverFarmId string

param isLinux bool = false
param appInsightsInstrumentationKey string = ''
param hasStagingSlot bool = false

var appServiceAppName = '${uniqPrefix}-app'

var appSettingKVPair = [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsightsInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: 'InstrumentationKey=${appInsightsInstrumentationKey}'
  }
  {
      name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
      value: '~2'
  }
  //This KV Pair here, is necessary on bicep or arm deployments. If it is not there the deployment will wipe the code files in production slot.
  //Further information can be found on our wiki, Incident Log with id: 00001
  {
      name: 'WEBSITE_RUN_FROM_PACKAGE'
      value: '1'
  }
]

var siteConfig = isLinux ? {
  linuxFxVersion: runtime
  appSettings : appSettingKVPair
  healthCheckPath: '/health'
  alwaysOn: true
} : {
  windowsFxVersion: runtime
  netFrameworkVersion: 'v7.0'
  appSettings : appSettingKVPair
  healthCheckPath: '/health'
  alwaysOn: true
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: serverFarmId
    httpsOnly: true
    siteConfig: siteConfig
  }
}

// Web App Staging Slot
resource webAppStagingSlot 'Microsoft.Web/sites/slots@2021-02-01' = if (hasStagingSlot) {
  parent: appServiceApp
  name: 'staging'
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarmId
  }
}

output webAppName string = appServiceAppName
output url string = appServiceApp.properties.defaultHostName
