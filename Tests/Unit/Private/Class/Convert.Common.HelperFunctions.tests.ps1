#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.psm1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module $modulePath -Force
#endregion
#region Test Setup
#endregion Test Setup
#region Tests
Describe 'Get-AvailableId' {
    # Since this function uses a global variable, we need to make sure we don't step on anything. 
    $resetglobalSettings = $false
    if ( $Global:StigSettings )
    {
        [System.Collections.ArrayList] $globalSettings = $Global:StigSettings
        $resetglobalSettings = $true
    }

    try 
    {
        It 'Should add the next available letter to an Id' {
            $Global:StigSettings = @(@{Id = 'V-1000'})
            Get-AvailableId -Id 'V-1000' | Should Be 'V-1000.a'
        }
    }
    finally
    {
        if ( $resetglobalSettings )
        {
            $Global:StigSettings = $globalSettings
        }
    }
}
#endregion
