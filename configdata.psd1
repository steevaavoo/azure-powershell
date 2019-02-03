@{
    ResourceGroupName = 'cl-dev-rg'
    Location          = 'EastUS'
    AdminUserName     = 'cladmin'
    AdminPassword     = 'G0ld5t4r!'

    VnetName          = 'cl-dev-vnet'
    VnetPrefix        = '192.168.0.0/16'

    Remote            = @{
        SubnetName   = 'cl-dev-remote-sub'
        SubnetPrefix = '192.168.1.0/24'
        VmName       = 'cl-jump-vm'
        NsgName      = 'cl-remote-nsg'
    }

    WSM               = @{
        SubnetName   = 'cl-dev-wsm-sub'
        SubnetPrefix = '192.168.14.0/24'
        VmName       = 'cl-wsm-dc'
        NsgName      = 'cl-wsm-nsg'
    }

    Portishead        = @{
        SubnetName   = 'cl-dev-ph-sub'
        SubnetPrefix = '192.168.15.0/24'
        VmName       = 'cl-ph-dc'
        NsgName      = 'cl-ph-nsg'
    }

    Winscombe         = @{
        SubnetName   = 'cl-dev-wins-sub'
        SubnetPrefix = '192.168.16.0/24'
        VmName       = 'cl-wins-dc'
        NsgName      = 'cl-wins-nsg'
    }
}
