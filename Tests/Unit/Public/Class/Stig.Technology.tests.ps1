using module .\..\..\..\..\Public\Class\Technology.psm1
#region HEADER
# Convert Public Class Header V1
using module ..\..\..\..\Public\Common\enum.psm1
. $PSScriptRoot\..\..\..\..\Public\Common\data.ps1
$ruleClassName = ($MyInvocation.MyCommand.Name -Split '\.')[0]

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.psm1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
#endregion
#region Test Setup
$testValidateSet = @('Windows','SQL')

$invalidName = 'Cheeseburger'
#endregion
#region Class Tests
Describe "Technology Class" {
    Context "Constructor" {
        foreach ($technology in $TestValidateSet)
        {
            It "Should create an Technology class instance using $technology data" {
                $newTechnology = [Technology]::new($technology)
                $newTechnology.Name | Should Be $technology
            }
        }

        It "Should throw an exception for Technology not being available: " {
            { [Technology]::new($InvalidName) } | Should Throw
        }
    }

    Context "Static Properties" {
        It "ValidateSet: Should match TestValidateSet to static ValidateSet property" {
            $ValidateSet = [Technology]::ValidateSet
            foreach ($Tech in $ValidateSet) 
            {
                $match = $TestValidateSet.Where({$_ -eq $Tech})
                $match | Should Be $Tech
            }
        }
    }

    Context "Instance Methods" {

        foreach ($technology in $TestValidateSet)
        {
            It "Validate: Should be able to validate $technology TechnologyRole. Valid property config." {
                $newTechnology = [Technology]::new()
                $newTechnology.Name = $technology
                $newTechnology.Validate() | Should Be $true
            }
        }

        It "Validate: Should be able to validate $technology TechnologyRole. Invalid property config." {
            $technology = [Technology]::new()
            $technology.Name = $InvalidName
            $technology.Validate() | Should Be $false
        }
    }

    Context "Static Methods" {
        It "Available: Should be able to return available technologies" {
            $validateSet = [Technology]::ValidateSet
            $available = [Technology]::Available()

            $available | Should Be $validateSet
        }
    }
}
#endregion
