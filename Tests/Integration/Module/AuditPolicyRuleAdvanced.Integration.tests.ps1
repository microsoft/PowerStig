#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $checkContent = 'Ensure Audit Process Creation auditing has been enabled:

Computer Configuration >> Windows Settings >> Security Settings >> Advanced Audit Policy Configuration >> System Audit Policy >> Detailed Tracking >> Audit Process Creation.

If "Audit Process Creation" is not set to "Failure", this is a finding.'

    Describe 'Advanced Audit Policy Conversion' {
        [xml] $stigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
        $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
        $stigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It 'Should return an AuditPolicyRuleAdvanced Object' {
            $rule.GetType() | Should Be 'AuditPolicyRuleAdvanced'
        }
        It 'Should extract the correct SubCategory' {
            $rule.SubCategory | Should Be 'Process Creation'
        }
        It 'Should extract the correct AuditFlag' {
            $rule.AuditFlag | Should be 'Failure'
        }
        It 'Should set the correct ensure value' {
            $rule.Ensure | Should be 'Present'
        }
        It 'Should set the correct DscResource' {
            $rule.DscResource | Should Be 'AuditPolicySubcategory'
        }
        It 'Should set the Conversion statud to pass ensure value' {
            $rule.conversionstatus | Should be 'pass'
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
