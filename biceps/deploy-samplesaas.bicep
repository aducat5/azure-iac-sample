targetScope = 'resourceGroup'

param appName string = 'sample-saas'
param tenant string
param defaultLocation string
param isLocked bool = false
// param isGeoReplicated bool = false
param databaseSKU object
param databaseHangfireSKU object
param appServiceSKU object
param isReview bool = false

var rg = resourceGroup()
var uniqAppName = isReview ? tenant : toLower('${tenant}-${appName}-${uniqueString(rg.id)}')

var serverFarmName = '${uniqAppName}-server'
// server farm will use the api app services name until the name change
var apiAppServiceName = '${uniqAppName}-api'
var webAppServiceName = '${uniqAppName}-web'
var sqlServerName = '${uniqAppName}-sql'
var storageAccountName = '${uniqAppName}-storage'
var appInsightsName = '${uniqAppName}-monitor'

module insights 'modules/appInsights.bicep' = {
  name: appInsightsName
  params: {
    uniqPrefix: appInsightsName
    location: defaultLocation
  }
}

module serverFarm 'modules/appServiceServerFarm.bicep' = {
  name: serverFarmName
  params: {
    isLinux: false
    uniqPrefix: apiAppServiceName
    location: defaultLocation
    planSKU: appServiceSKU
  }
}

module apiAppService 'modules/appServiceWebSite.bicep' = {
  name: apiAppServiceName
  params: {
    uniqPrefix: apiAppServiceName
    serverFarmId: serverFarm.outputs.serverFarmId
    location: defaultLocation
    runtime: 'dotnet:7'
    appInsightsInstrumentationKey: insights.outputs.instrumentationKey
    hasStagingSlot: (appServiceSKU.tier == 'Standard' || appServiceSKU.tier == 'Premium')
  }
}

module webAppService 'modules/appServiceWebSite.bicep' = {
  name: webAppServiceName
  params: {
    uniqPrefix: webAppServiceName
    serverFarmId: serverFarm.outputs.serverFarmId
    location: defaultLocation
    runtime: 'NODE:18LTS'
  }
}

module database 'modules/sqlServer.bicep' = {
  name: sqlServerName
  params: {
    uniqPrefix: sqlServerName
    location: defaultLocation
    // isGeoReplicated: isGeoReplicated
    databaseSKU: databaseSKU
    databaseHangfireSKU: databaseHangfireSKU
  }
}

module storage 'modules/storageAccount.bicep' = {
  name: storageAccountName
  params: {
    location: defaultLocation
    uniqPrefix: toLower(tenant) 
  }
}

//locks the resource group if asked

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if(isLocked) {
  name: 'resourceGroupLock'
  properties: {
    level: 'CanNotDelete'
    notes: 'Lock to prevent resource group and its resources from being deleted'
  }
}

output sqlConnection string = database.outputs.sqlConnectionString
output hangfireConnection string = database.outputs.hangfireConnectionString
output storageConnection string = storage.outputs.blobStorageConnectionString

output apiAppName string = apiAppService.outputs.webAppName
output webAppName string = webAppService.outputs.webAppName

output apiAppUrl string = 'https://${apiAppService.outputs.url}'
output webAppUrl string = 'https://${webAppService.outputs.url}'
