<#
    .SYNOPSIS
        Apply the DotNetFramework 4.0 STIG to a node

    .DESCRIPTION
        In this example, the DotNetFramework 4.0 STIG is processed by the composite resource
#>
Configuration Example
{
    param
    (
        [parameter()]
        [string]
        $NodeName = 'localhost'
    )

    Import-DscResource -ModuleName PowerStig

    Node $NodeName
    {
        DotNetFramework DotNetConfiguration
        {
            FrameworkVersion = 'DotNet4'
            Stigversion    = '1.4'
        }
    }
}

Example
