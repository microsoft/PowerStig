Configuration xRegistry_config
{
    param
    ( )

    Import-Module $PSScriptRoot\..\..\..\DscResources\helper.psm1 -Force
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.3.0.0

    Node localhost
    {
        . $PSScriptRoot\..\..\..\DscResources\Resources\windows.xRegistry.ps1
    }
}
