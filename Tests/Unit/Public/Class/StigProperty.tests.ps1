using module .\..\..\..\..\Public\Class\StigProperty.psm1
#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.ps1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ((-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))))
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
#endregion

$StigPropertyTest =
@{
    'ValueData' = '2';
    'Identity' = 'Administrators,Local Service'
}

Describe "StigProperty Class" {

    Context "Constructor" {

        It "Should create an StigProperty class instance using StigProperty1 data" {
            foreach ($property in $StigPropertyTest.GetEnumerator())
            {
                $stigProperty = [StigProperty]::new($property.Key, $property.Value)
                $stigProperty.Name | Should Be $property.Key
                $stigProperty.Value | Should Be $property.Value
            }
        }
    }
}
