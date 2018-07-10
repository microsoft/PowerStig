#region Header
using module .\..\..\..\Module\Stig.StigException\Stig.StigException.psm1
using module .\..\..\..\Module\Stig.StigProperty\Stig.StigProperty.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $StigException1StigRuleId = 'V-26606'
    $StigException1StigProperty1 = [StigProperty]::new('ServiceState', 'Running')
    $StigException1StigProperty2 = [StigProperty]::new('StartupType', 'Automatic')
    $StigException1StigProperty = @($StigException1StigProperty1, $StigException1StigProperty2)

    $StigExceptionAddMethodStigProperty1 = [StigProperty]::new('ServiceState', 'Running')
    $StigExceptionAddMethodNameValue1 = @{'Name' = 'ServiceState'; 'Value' = 'Running'}

    [hashtable] $StigExceptionHashtable =
    @{
        "V-26606" = @{'ServiceState' = 'Running';
            'StartupType'            = 'Automatic'
        };
        "V-15683" = @{'ValueData' = '1'};
        "V-26477" = @{'Identity' = 'Administrators'};
    }
    #endregion
    #region Class Tests
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
                    $stigException = $StigExceptions.Where( {$_.StigRuleId -eq $hash.Key})
                    $stigException.StigRuleId | Should Be $hash.Key

                    foreach ($property in $hash.Value.GetEnumerator())
                    {
                        $stigProperty = $stigException.Properties.Where( {$_.Name -eq $property.Key})
                        $stigProperty.Name | Should Be $property.Key
                        $stigProperty.Value | Should Be $property.Value
                    }
                }
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
