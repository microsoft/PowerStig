# DscResource Unit Test Header
. $PSScriptRoot\.tests.header.ps1

configuration Registry_config
{
    param
    ( )

    Import-Module $moduleRoot\DscResources\helper.psm1 -Force
    Import-DscResource -ModuleName GPRegistryPolicyDsc -ModuleVersion 1.3.1
    Import-DscResource -ModuleName PSDSCresources -ModuleVersion 2.12.0.0

    Node localhost
    {
        . $moduleRoot\DscResources\Resources\windows.Registry.ps1
    }
}
