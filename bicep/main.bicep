targetScope = 'resourceGroup'

@description('Deployment location. Defaults to resource group location.')
param location string = resourceGroup().location

@description('Environment name (dev|test|prod).')
@allowed([
  'dev'
  'test'
  'prod'
])
param env string = 'dev'

@description('Short application/workload name used in resource naming.')
param workloadName string

@description('Common tags applied to all resources.')
param tags object = {
  workload: workloadName
  environment: env
  managedBy: 'bicep'
}

@description('Whether to enable Log Analytics (kept optional to avoid costs).')
param monitoringEnabled bool = false

@description('Whether to create a Storage Account (secure defaults).')
param storageEnabled bool = true

@description('Virtual network address space.')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Subnet prefix for mgmt subnet.')
param subnetMgmtPrefix string = '10.10.1.0/24'

@description('Subnet prefix for workload subnet.')
param subnetWorkloadPrefix string = '10.10.2.0/24'

// Monitoring module is ALWAYS deployed (module is never null)
// It creates resources only when enabled=true
module monitoring 'modules/monitoring.bicep' = {
  name: 'mod-monitoring-${env}'
  params: {
    enabled: monitoringEnabled
    location: location
    tags: tags
    env: env
    workloadName: workloadName
  }
}

var logAnalyticsWorkspaceId = monitoring.outputs.workspaceId

module network 'modules/network.bicep' = {
  name: 'mod-network-${env}'
  params: {
    location: location
    tags: tags
    env: env
    workloadName: workloadName
    vnetAddressPrefix: vnetAddressPrefix
    subnetMgmtPrefix: subnetMgmtPrefix
    subnetWorkloadPrefix: subnetWorkloadPrefix
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// Storage module is ALWAYS deployed (module is never null)
// It creates resources only when enabled=true
module storage 'modules/storage.bicep' = {
  name: 'mod-storage-${env}'
  params: {
    enabled: storageEnabled
    location: location
    tags: tags
    env: env
    workloadName: workloadName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

output vnetId string = network.outputs.vnetId
output subnetMgmtId string = network.outputs.subnetMgmtId
output subnetWorkloadId string = network.outputs.subnetWorkloadId

output logAnalyticsWorkspaceId string = logAnalyticsWorkspaceId
output storageAccountId string = storage.outputs.storageAccountId
