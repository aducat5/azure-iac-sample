param location string = 'West Europe'
param uniqPrefix string
param isLinux bool
param planSKU object = {
  name: 'B1'
  tier: 'Basic'
  size: 'B1'
  family: 'B'
  capacity: 1
}
var appServicePlanName = '${uniqPrefix}-plan'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: isLinux ? 'linux' : 'windows'
  sku: planSKU
  properties: {
    reserved: isLinux
  }
}

output serverFarmId string = appServicePlan.id
