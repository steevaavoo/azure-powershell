@{
    ResourceGroupName = 'br-dev-rg'
    Location          = 'EastUS'
    AdminUserName     = 'bradmin'
    AdminPassword     = 'G0ld5t4r!'

    VnetName          = 'br-dev-vnet'
    VnetPrefix        = '192.168.0.0/16'

    Remote            = @{
        SubnetName   = 'br-dev-remote-sub'
        SubnetPrefix = '192.168.1.0/24'
        VmName       = 'br-jump-vm'
        NsgName      = 'br-remote-nsg'
    }

    WSM               = @{
        SubnetName   = 'br-dev-wsm-sub'
        SubnetPrefix = '192.168.14.0/24'
        VmName       = 'br-wsm-dc'
        NsgName      = 'br-wsm-nsg'
    }

    Portishead        = @{
        SubnetName   = 'br-dev-ph-sub'
        SubnetPrefix = '192.168.15.0/24'
        VmName       = 'br-ph-dc'
        NsgName      = 'br-ph-nsg'
    }

    Winscombe         = @{
        SubnetName   = 'br-dev-wins-sub'
        SubnetPrefix = '192.168.16.0/24'
        VmName       = 'br-wins-dc'
        NsgName      = 'br-wins-nsg'
    }
}
