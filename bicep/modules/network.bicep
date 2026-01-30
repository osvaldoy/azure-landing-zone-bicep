@description('Deployment location.')
param location string

@description('Common tags.')
param tags object

@description('Environment name.')
param env string

@description('Workload name.')
param workloadName string

@description('VNet address space.')
param vnetAddressPrefix string

@description('Mgmt subnet prefix.')
param subnetMgmtPrefix string

@description('Workload subnet prefix.')
param subnetWorkloadPrefix string

@description('Optional Log Analytics Workspace resource ID for diagnostics. Use empty string to disable.')
param logAnalyticsWorkspaceId string = ''

var namePrefix = toLower('${workloadName}-${env}')
var vnetName = '${namePrefix}-vnet'
var nsgMgmtName = '${namePrefix}-nsg-mgmt'
var nsgWorkloadName = '${namePrefix}-nsg-work'

resource nsgMgmt 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgMgmtName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTPS-Inbound-From-VNet'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource nsgWork 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgWorkloadName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-IntraVnet'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [vnetAddressPrefix] }
    subnets: [
      {
        name: 'snet-mgmt'
        properties: {
          addressPrefix: subnetMgmtPrefix
          networkSecurityGroup: { id: nsgMgmt.id }
        }
      }
      {
        name: 'snet-workloads'
        properties: {
          addressPrefix: subnetWorkloadPrefix
          networkSecurityGroup: { id: nsgWork.id }
        }
      }
    ]
  }
}

// Optional diagnostics to Log Analytics (kept simple; you can expand categories later)
resource vnetDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (logAnalyticsWorkspaceId != '') {
  name: '${vnet.name}-diag'
  scope: vnet
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: false
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output vnetId string = vnet.id
output subnetMgmtId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'snet-mgmt')
output subnetWorkloadId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'snet-workloads')
