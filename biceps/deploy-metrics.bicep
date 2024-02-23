targetScope = 'resourceGroup'

param tenant string
param appName string
param defaultLocation string = 'westeurope'

var rg = resourceGroup()

var uniqAppName =  toLower('${tenant}-${appName}-${uniqueString(rg.id)}')
var sqlServerName = '${uniqAppName}-sql-server'
var sqlDbName = '${uniqAppName}-sql-db'

var resourceGroupExternalId = '/subscriptions/<subscription-id>/resourceGroups/${tenant}'
var sqlServerExternalId = '${resourceGroupExternalId}/providers/Microsoft.Sql/servers/${sqlServerName}'
var sqlDbExternalId = '${sqlServerExternalId}/databases/${sqlDbName}'
var actionGroupExternalId = '/subscriptions/<subscription-id>/resourceGroups/shared/providers/microsoft.insights/actiongroups/resource down'

module metricAlertDiskAbove80 'modules/sqlMetricRules.bicep' = {
  name: '${uniqAppName}-sql-metric-alerts'
  params: {
    actionGroupExternalId: actionGroupExternalId
    location: defaultLocation
    sqlDbExternalId: sqlDbExternalId
  }
}
