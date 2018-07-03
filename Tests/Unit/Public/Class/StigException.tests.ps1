using module .\..\..\..\..\Public\Class\StigException.psm1
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

$StigException1StigRuleId = 'V-26606'
$StigException1StigProperty1 = [StigProperty]::new('ServiceState', 'Running')
$StigException1StigProperty2 = [StigProperty]::new('StartupType', 'Automatic')
$StigException1StigProperty = @($StigException1StigProperty1, $StigException1StigProperty2)

$StigExceptionAddMethodStigProperty1 = [StigProperty]::new('ServiceState', 'Running')
$StigExceptionAddMethodNameValue1 = @{'Name'='ServiceState';'Value'='Running'}

[hashtable] $StigExceptionHashtable =
@{
    "V-26606" = @{'ServiceState' = 'Running';
                'StartupType'= 'Automatic'};
    "V-15683" = @{'ValueData' = '1'};
    "V-26477" = @{'Identity' = 'Administrators'};
}

Describe "StigException Class" {

    Context "Constructor" {

        It "Should create an StigException class instance using StigException1 data" {
            $StigException = [StigException]::new($StigException1StigRuleId, $StigException1StigProperty)
            $StigException.StigRuleId | Should Be $StigException1StigRuleId
            $StigException.Properties | Should Be $StigException1StigProperty
        }
    }

    Context "Instance Methods" {
        It "AddProperty: Should be able to add a StigProperty instance." {
            $StigException = [StigException]::new()
            $StigException.StigRuleId = $StigException1StigRuleId
            $StigException.AddProperty($StigExceptionAddMethodStigProperty1)

            $StigProperties = $StigException.Properties
            $StigProperty = $StigProperties.Where( {$_.Name -eq $StigExceptionAddMethodStigProperty1.Name})
            $StigProperty.Name | Should Be $StigExceptionAddMethodStigProperty1.Name
            $StigProperty.Value | Should Be $StigExceptionAddMethodStigProperty1.Value
        }

        It "AddProperty: Should be able to add a StigProperty equivalent Name/Value pair." {
            $StigException = [StigException]::new()
            $StigException.StigRuleId = $StigException1StigRuleId
            $StigException.AddProperty($StigExceptionAddMethodNameValue1.Name, $StigExceptionAddMethodNameValue1.Value)

            $StigProperties = $StigException.Properties
            $StigProperty = $StigProperties.Where( {$_.Name -eq $StigExceptionAddMethodNameValue1.Name})
            $StigProperty.Name | Should Be $StigExceptionAddMethodNameValue1.Name
            $StigProperty.Value | Should Be $StigExceptionAddMethodNameValue1.Value
        }
    }

    Context "Static Methods" {
        It "ConvertFrom: Should be able to convert an Hashtable to a StigException array" {
            $StigExceptions = [StigException]::ConvertFrom($StigExceptionHashtable)

            foreach ($hash in $StigExceptionHashtable.GetEnumerator())
            {
                $stigException = $StigExceptions.Where({$_.StigRuleId -eq $hash.Key})
                $stigException.StigRuleId | Should Be $hash.Key

                foreach ($property in $hash.Value.GetEnumerator())
                {
                    $stigProperty = $stigException.Properties.Where({$_.Name -eq $property.Key})
                    $stigProperty.Name | Should Be $property.Key
                    $stigProperty.Value | Should Be $property.Value
                }
            }
        }
    }
}
