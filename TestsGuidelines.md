# Testing

## Unit Testing

### Unit Testing Template

Copy the following snipet of code into a new test file and update the TO DO items.

```PowerShell
#region Header
using module .\..\..\..\Module\Convert.xRule\Convert.xRule.psm1 # TO DO - Update the path to the module
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup

        #endregion
        #region Class Tests

        # TO DO - Add test from Unit\Public\Class Class Region

        #endregion
        #region Method Tests

        # TO DO - Add test from Unit\Public\Class Method Region

        #endregion
        #region Function Tests

        # TO DO - Add test from Unit\Private\Class

        #endregion
        #region Data Tests

        # TO DO - Add test from Unit\Public\Data

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
```

## Integration Testing

### Integration Testing Template

Copy the following snipet of code into a new *.integration.tests.ps1 test file and add your integration tests.

```PowerShell
#region Header
. $PSScriptRoot\.tests.Header.ps1
#endregion
try
{
    #region Test Setup

    #endregion
    #region Tests

    #endregion
}
finally
{
    . $PSScriptRoot\.tests.Footer.ps1
}
```
