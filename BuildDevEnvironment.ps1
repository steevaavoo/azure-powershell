$configData = Import-PowerShellDataFile -Path '.\configdata.psd1'

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
}
New-AzVM @jumpVMSplat -Verbose