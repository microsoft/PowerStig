configuration Registry_config
{
    param
    ( )

    Import-Module $PSScriptRoot\..\..\..\DscResources\helper.psm1 -Force
    Import-DscResource -ModuleName GPRegistryPolicyDsc -ModuleVersion 1.0.1
    Import-DscResource -ModuleName PSDscResources -ModuleVersion 2.10.0.0

    Node localhost
    {
        . $PSScriptRoot\..\..\..\DscResources\Resources\windows.Registry.ps1
    }
}
