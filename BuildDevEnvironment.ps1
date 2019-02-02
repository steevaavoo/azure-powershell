$configData = Import-PowerShellDataFile -Path '.\configdata.psd1'

<#
Cleanup Tasks
Remove-AzResourceGroup -Name $configData.ResourceGroupName -Force -Verbose -AsJob
#>

# Build Resource Group
New-AzResourceGroup -ResourceGroupName $configData.ResourceGroupName -Location $configData.Location

# Define the Remote Subnet - for external access and admin
$remoteSubnetSplat = @{
    Name          = $configData.Remote.SubnetName
    AddressPrefix = $configData.Remote.SubnetPrefix
}
$remoteSubnet = New-AzVirtualNetworkSubnetConfig @remoteSubnetSplat -Verbose

# Define the WSM (Master Domain) Subnet
$wsmSubnetSplat = @{
    Name          = $configData.WSM.SubnetName
    AddressPrefix = $configData.WSM.SubnetPrefix
}
$wsmSubnet = New-AzVirtualNetworkSubnetConfig @wsmSubnetSplat -Verbose

# Define the Portishead Subnet
$portisheadSubnetSplat = @{
    Name          = $configData.Portishead.SubnetName
    AddressPrefix = $configData.Portishead.SubnetPrefix
}
$portisheadSubnet = New-AzVirtualNetworkSubnetConfig @portisheadSubnetSplat -Verbose

# Define the Winscombe Subnet
$winscombeSubnetSplat = @{
    Name          = $configData.Winscombe.SubnetName
    AddressPrefix = $configData.Winscombe.SubnetPrefix
}
$winscombeSubnet = New-AzVirtualNetworkSubnetConfig @winscombeSubnetSplat -Verbose

# Build the VNet to encapsulate the above Subnets
$vnetSplat = @{
    ResourceGroupName = $configData.ResourceGroupName
    Location          = $configData.Location
    Name              = $configData.VnetName
    AddressPrefix     = $configData.VnetPrefix
    Subnet            = $remoteSubnet, $wsmSubnet, $portisheadSubnet, $winscombeSubnet
}
$vnet = New-AzVirtualNetwork @vnetSplat -Verbose

# Create a Public IP for the Jump Server
$pipSplat = @{
    ResourceGroupName = $configData.ResourceGroupName
    Location          = $configData.Location
    AllocationMethod  = 'Dynamic'
    Name              = 'JumpPIP'
}
$pip = New-AzPublicIpAddress @pipSplat -Verbose

# Building Credential for VMs
$credential = [pscredential]::new($configData.AdminUserName, (ConvertTo-SecureString -String $configData.AdminPassword -asPlainText -Force ))


#region NetworkSecurity

# Defining Internal Network Security Rules
$ruleAllInboundAllowSplat = @{
    Name                     = 'internalcomms-rule-inbound'
    Description              = 'Allow All Internal Comms Inbound'
    Access                   = 'Allow'
    Protocol                 = 'Tcp'
    Direction                = 'Inbound'
    Priority                 = 100
    SourceAddressPrefix      = '192.168.0.0/16'
    SourcePortRange          = '*'
    DestinationAddressPrefix = '*'
    DestinationPortRange     = '*'
}
$ruleAllInboundAllow = New-AzNetworkSecurityRuleConfig @ruleAllInboundAllowSplat

#region RemoteNetworking
# Defining Network Security Rules for Jump Server
$ruleRDPAllowSplat = @{
    Name                     = 'rdp-rule'
    Description              = 'Allow RDP'
    Access                   = 'Allow'
    Protocol                 = 'Tcp'
    Direction                = 'Inbound'
    Priority                 = 100
    SourceAddressPrefix      = 'Internet'
    SourcePortRange          = '*'
    DestinationAddressPrefix = '*'
    DestinationPortRange     = '3389'
}
$ruleRDPAllow = New-AzNetworkSecurityRuleConfig @ruleRDPAllowSplat

# Building Network Security Group for Jump Server
$nsgRemoteSplat = @{
    ResourceGroupName = $configData.ResourceGroupName
    Location          = $configData.Location
    Name              = $configData.Remote.NsgName
    SecurityRules     = $ruleRDPAllow
}
$nsgRemote = New-AzNetworkSecurityGroup @nsgRemoteSplat

# Updating the Vnet Config with the Network Security Group Information
$remoteSubnetConfigSplat = @{
    VirtualNetwork       = $vnet
    Name                 = $configdata.Remote.SubnetName
    AddressPrefix        = $configData.Remote.SubnetPrefix
    NetworkSecurityGroup = $nsgRemote
}
$remoteSubnetConfig = Set-AzVirtualNetworkSubnetConfig @remoteSubnetConfigSplat -Verbose
#endregion RemoteNetworking


#region WSMNetworking

# Building Network Security Group for WSM Server
$nsgWsmSplat = @{
    ResourceGroupName = $configData.ResourceGroupName
    Location          = $configData.Location
    Name              = $configData.WSM.NsgName
    SecurityRules     = $ruleAllInboundAllow
}
$nsgWSM = New-AzNetworkSecurityGroup @nsgWsmSplat

# Updating the Vnet Config with the Network Security Group Information
$wsmSubnetConfigSplat = @{
    VirtualNetwork       = $vnet
    Name                 = $configdata.WSM.SubnetName
    AddressPrefix        = $configData.WSM.SubnetPrefix
    NetworkSecurityGroup = $nsgWSM
}
$wsmSubnetConfig = Set-AzVirtualNetworkSubnetConfig @wsmSubnetConfigSplat -Verbose
#endregion WSMNetworking


#region WinscombeNetworking
# Building Network Security Group for Winscombe Server
$nsgWinscombeSplat = @{
    ResourceGroupName = $configData.ResourceGroupName
    Location          = $configData.Location
    Name              = $configData.Winscombe.NsgName
    SecurityRules     = $ruleAllInboundAllow
}
$nsgWinscombe = New-AzNetworkSecurityGroup @nsgWinscombeSplat

# Updating the Vnet Config with the Network Security Group Information
$winscombeSubnetConfigSplat = @{
    VirtualNetwork       = $vnet
    Name                 = $configdata.Winscombe.SubnetName
    AddressPrefix        = $configData.Winscombe.SubnetPrefix
    NetworkSecurityGroup = $nsgWinscombe
}
$winscombeSubnetConfig = Set-AzVirtualNetworkSubnetConfig @winscombeSubnetConfigSplat -Verbose
#endregion WinscombeNetworking


#region PortisheadNetworking
# Building Network Security Group for Portishead Server
$nsgPortisheadSplat = @{
    ResourceGroupName = $configData.ResourceGroupName
    Location          = $configData.Location
    Name              = $configData.Portishead.NsgName
    SecurityRules     = $ruleAllInboundAllow
}
$nsgPortishead = New-AzNetworkSecurityGroup @nsgPortisheadSplat

# Updating the Vnet Config with the Network Security Group Information
$portisheadSubnetConfigSplat = @{
    VirtualNetwork       = $vnet
    Name                 = $configdata.Portishead.SubnetName
    AddressPrefix        = $configData.Portishead.SubnetPrefix
    NetworkSecurityGroup = $nsgPortishead
}
$portisheadSubnetConfig = Set-AzVirtualNetworkSubnetConfig @portisheadSubnetConfigSplat -Verbose
#endregion PortisheadNetworking


# Applying the new Vnet Config
Set-AzVirtualNetwork -VirtualNetwork $vnet -Verbose
#endregion NetworkSecurity

#region BuildVMs
# Building the Jump VM
$jumpVMSplat = @{
    Credential          = $credential
    Name                = $configData.Remote.VmName
    PublicIpAddressName = 'JumpPIP'
    ResourceGroupName   = $configData.ResourceGroupName
    Location            = $configData.Location
    Size                = 'Standard_D1'
    SubnetName          = $configData.Remote.SubnetName
    VirtualNetworkName  = $configData.VnetName
    SecurityGroupName   = $configData.Remote.NsgName
    AsJob               = $true
}
New-AzVM @jumpVMSplat -Verbose

# Building the WSM DC
$wsmVMSplat = @{
    Credential         = $credential
    Name               = $configData.WSM.VmName
    ResourceGroupName  = $configData.ResourceGroupName
    Location           = $configData.Location
    Size               = 'Standard_D1'
    SubnetName         = $configData.WSM.SubnetName
    VirtualNetworkName = $configData.VnetName
    SecurityGroupName  = $configData.WSM.NsgName
    AsJob              = $true
}
New-AzVM @wsmVMSplat -Verbose

# Building the Winscombe DC
$winscombeVMSplat = @{
    Credential         = $credential
    Name               = $configData.Winscombe.VmName
    ResourceGroupName  = $configData.ResourceGroupName
    Location           = $configData.Location
    Size               = 'Standard_D1'
    SubnetName         = $configData.Winscombe.SubnetName
    VirtualNetworkName = $configData.VnetName
    SecurityGroupName  = $configData.Winscombe.NsgName
    AsJob              = $true
}
New-AzVM @winscombeVMSplat -Verbose

# Building the Portishead DC
$portisheadVMSplat = @{
    Credential         = $credential
    Name               = $configData.Portishead.VmName
    ResourceGroupName  = $configData.ResourceGroupName
    Location           = $configData.Location
    Size               = 'Standard_D1'
    SubnetName         = $configData.Portishead.SubnetName
    VirtualNetworkName = $configData.VnetName
    SecurityGroupName  = $configData.Portishead.NsgName
    AsJob              = $true
}
New-AzVM @portisheadVMSplat -Verbose
#endregion BuildVMs

# Monitor each VM creation Job and return results as they complete
Get-Job | Receive-Job -Wait
