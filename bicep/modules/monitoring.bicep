@description('Enable/disable monitoring resources.')
param enabled bool = false

@description('Deployment location.')
param location string

@description('Common tags.')
param tags object

@description('Environment name.')
param env string

@description('Workload name.')
param workloadName string

var namePrefix = toLower('${workloadName}-${env}')
var lawName = '${namePrefix}-law'

// Create LAW only when enabled
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (enabled) {
  name: lawName
  location: location
  tags: tags
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Outputs: compute IDs without referencing conditional symbol in a risky way
output workspaceId string = enabled ? resourceId('Microsoft.OperationalInsights/workspaces', lawName) : ''
output workspaceName string = enabled ? lawName : ''
