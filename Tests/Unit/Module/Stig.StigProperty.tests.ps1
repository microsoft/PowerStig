#region Header
using module .\..\..\..\Module\Stig.StigProperty\Stig.StigProperty.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $StigPropertyTest = @{
        'ValueData' = '2';
        'Identity'  = 'Administrators,Local Service'
    }
    #endregion
    #region Class Tests
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
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
