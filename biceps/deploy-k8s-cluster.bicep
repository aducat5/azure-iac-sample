targetScope = 'resourceGroup'

param appName string
param tenant string
param defaultLocation string

var rg = resourceGroup()
var uniqAppName = toLower('${tenant}-${appName}-${uniqueString(rg.id)}')

var clusterName = '${uniqAppName}-cluster'
var acrName = 'sample-review'
var sshRSAPublicKey = ''

module mainCluster 'modules/azureKubernetesService.bicep' = {
  name: clusterName
  params: {
    clusterName: clusterName
    dnsPrefix: uniqAppName
    linuxAdminUsername: 'sample-root'
    sshRSAPublicKey: sshRSAPublicKey
    location: defaultLocation
  }
}

module containerRegistry 'modules/azureContainerRegistry.bicep' = {
  name: acrName
  params: {
    location: defaultLocation
    acrName: acrName
  }
}
