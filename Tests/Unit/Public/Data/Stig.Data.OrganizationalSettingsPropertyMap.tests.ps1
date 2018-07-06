#region Header
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.psd1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/Microsoft/PowerStig.Tests', (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force

$psDataFilePath = $script:modulePath -replace '\.ps1','.psd1'
#endregion
#region Test Setup

#endregion
#region Tests
Describe "OrganizationalSettings Property Map" {
    
    $propertyList = @('AccountPolicyRule', 'AuditPolicyRule', 'RegistryRule',
        'SecurityOptionRule', 'ServiceRule', 'UserRightRule', 'WebAppPoolRule',
        'WebConfigurationPropertyRule')

    [psobject] $PowerShellDataFile = Import-PowerShellDataFile -Path $psDataFilePath

    foreach ($property in $propertyList)
    {
        It "Should have a $property property" {
            $PowerShellDataFile.$property | Should Not BeNullOrEmpty
        }
    }

    <# 
    TO DO - Add rules 
    #>
}
#endregion Tests
