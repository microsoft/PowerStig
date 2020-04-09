# DscResource Unit Test Header
. $PSScriptRoot\.tests.header.ps1

configuration Registry_config
{
    param
    ( )

    Import-Module $moduleRoot\DscResources\helper.psm1 -Force
    Import-DscResource -ModuleName GPRegistryPolicyDsc -ModuleVersion 1.2.0
    Import-DscResource -ModuleName PSDscResources -ModuleVersion 2.10.0.0

    Node localhost
    {
        . $moduleRoot\DscResources\Resources\windows.Registry.ps1
    }
}
