@description('Enable/disable storage account.')
param enabled bool = true

@description('Deployment location.')
param location string

@description('Common tags.')
param tags object

@description('Environment name.')
param env string

@description('Workload name.')
param workloadName string

@description('Optional Log Analytics Workspace resource ID for diagnostics. Use empty string to disable.')
param logAnalyticsWorkspaceId string = ''

// Storage account name constraints:
// - 3-24 chars
// - lowercase letters and numbers only
var baseName = toLower(replace('${workloadName}${env}', '-', ''))
var uniq = uniqueString(resourceGroup().id, workloadName, env)
var saName = take('${baseName}${uniq}', 24)

resource sa 'Microsoft.Storage/storageAccounts@2023-05-01' = if (enabled) {
  name: saName
  location: location
  tags: tags
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: { enabled: true }
        file: { enabled: true }
      }
    }
  }
}

resource saDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enabled && logAnalyticsWorkspaceId != '') {
  name: '${saName}-diag'
  scope: sa
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      { category: 'StorageRead', enabled: true }
      { category: 'StorageWrite', enabled: true }
      { category: 'StorageDelete', enabled: true }
    ]
    metrics: [
      { category: 'AllMetrics', enabled: true }
    ]
  }
}

output storageAccountId string = enabled ? resourceId('Microsoft.Storage/storageAccounts', saName) : ''
output storageAccountName string = enabled ? saName : ''
