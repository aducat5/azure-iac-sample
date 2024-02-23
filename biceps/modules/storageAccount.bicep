// StorageAccount.bicep

@minLength(3)
@maxLength(16)
param uniqPrefix string

param location string = resourceGroup().location
param tags object = {}
param storageAccountSku string = 'Standard_LRS'
param storageAccountType string = 'StorageV2'
param containerNames array = []

var storageAccountName = replace('${uniqPrefix}storage', '-', '')

// Create storage
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountType
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    restorePolicy: {
      enabled: true
      days: 14
    }
    changeFeed: {
      enabled: true
      retentionInDays: 14
    }
    isVersioningEnabled: true
    deleteRetentionPolicy: {
      days: 15
      enabled: true
    }
  }
}

// Create containers if specified
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = [for containerName in containerNames: {
  parent: blobService
  name: !empty(containerNames) ? '${toLower(containerName)}' : 'placeholder'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}]

var blobStorageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'

output blobStorageConnectionString string = blobStorageConnectionString 
