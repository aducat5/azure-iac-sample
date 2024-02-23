param sqlDbExternalId string
param actionGroupExternalId string
param location string

var cpuAlertName = 'metric-cpu-above-80'
var dataIOAlertName = 'metric-data-io-above-80'
var dataSpaceAlertName = 'metric-data-space-above-80'
var sqlMemoryAlertName = 'metric-sql-memory-above-80'

resource metricAlerts_CPU_above_80_name_resource 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: cpuAlertName
  location: 'global'
  properties: {
    severity: 3
    enabled: true
    scopes: [
      sqlDbExternalId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: 80
          name: 'Metric1'
          metricNamespace: 'Microsoft.Sql/servers/databases'
          metricName: 'cpu_percent'
          operator: 'GreaterThan'
          timeAggregation: 'Maximum'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Sql/servers/databases'
    targetResourceRegion: location
    actions: [
      {
        actionGroupId: actionGroupExternalId
        webHookProperties: {}
      }
    ]
  }
}

resource metricAlerts_Data_IO_above_80_name_resource 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: dataIOAlertName
  location: 'global'
  properties: {
    severity: 3
    enabled: true
    scopes: [
      sqlDbExternalId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: 80
          name: 'Metric1'
          metricNamespace: 'Microsoft.Sql/servers/databases'
          metricName: 'physical_data_read_percent'
          operator: 'GreaterThan'
          timeAggregation: 'Maximum'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Sql/servers/databases'
    targetResourceRegion: location
    actions: [
      {
        actionGroupId: actionGroupExternalId
        webHookProperties: {}
      }
    ]
  }
}

resource metricAlerts_Data_space_above_80_name_resource 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: dataSpaceAlertName
  location: 'global'
  properties: {
    severity: 3
    enabled: true
    scopes: [
      sqlDbExternalId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: 80
          name: 'Metric1'
          metricNamespace: 'Microsoft.Sql/servers/databases'
          metricName: 'storage_percent'
          operator: 'GreaterThan'
          timeAggregation: 'Maximum'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Sql/servers/databases'
    targetResourceRegion: location
    actions: [
      {
        actionGroupId: actionGroupExternalId
        webHookProperties: {
        }
      }
    ]
  }
}

resource metricAlerts_SQL_Memory_above_80_name_resource 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: sqlMemoryAlertName
  location: 'global'
  properties: {
    severity: 3
    enabled: true
    scopes: [
      sqlDbExternalId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: 80
          name: 'Metric1'
          metricNamespace: 'Microsoft.Sql/servers/databases'
          metricName: 'sqlserver_process_memory_percent'
          operator: 'GreaterThan'
          timeAggregation: 'Maximum'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Sql/servers/databases'
    targetResourceRegion: location
    actions: [
      {
        actionGroupId: actionGroupExternalId
        webHookProperties: {}
      }
    ]
  }
}
