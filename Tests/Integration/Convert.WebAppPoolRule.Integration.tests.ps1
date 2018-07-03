#region Header
using module ..\..\..\release\PowerStigConvert\PowerStigConvert.psd1
. $PSScriptRoot\..\..\helper.ps1
#endregion Header
#region Test Setup
$stigRulesToTest = @(
    @{
        Key           = 'rapidFailProtection'
        Value         = '$true'
        CheckContent  = 'Open the IIS 8.5 Manager.

        Click the Application Pools.
        
        Perform for each Application Pool.
        
        Highlight an Application Pool to review and click "Advanced Settings" in the "Actions" pane.
        
        Scroll down to the "Rapid Fail Protection" section and verify the value for "Enabled" is set to "True".
        
        If the "Rapid Fail Protection:Enabled" is not set to "True", this is a finding.'
    }
    @{
        Key           = 'pingingEnabled'
        Value         = '$true'
        CheckContent  = 'Open the IIS 8.5 Manager.

        Click the Application Pools.
        
        Perform for each Application Pool.
        
        Highlight an Application Pool to review and click "Advanced Settings" in the "Actions" pane.
        
        Scroll down to the "Process Model" section and verify the value for "Ping Enabled" is set to "True".

        If the value for "Ping Enabled" is not set to "True", this is a finding.'
    }
)
#endregion Test Setup
#region Tests
Describe "WebAppPool Rule Conversion" {

    foreach ( $stig in $stigRulesToTest )
    {
        [xml] $StigRule = Get-TestStigRule -CheckContent $stig.CheckContent -XccdfTitle 'IIS'
        $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
        $StigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It "Should return an WebAppPoolRule Object" {
            $rule.GetType() | Should Be 'WebAppPoolRule'
        }

        It "Should return Key '$($stig.Key)'" {
            $rule.Key | Should Be $stig.Key
        }

        It "Should return Value '$($stig.Value)'" {
            $rule.Value | Should Be $stig.Value
        }

        It 'Should Set the status to pass' {
            $rule.ConversionStatus | Should Be 'pass'
        }
    }
}
#endregion Tests
