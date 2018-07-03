#region Header
using module ..\..\..\release\PowerStigConvert\PowerStigConvert.psd1
. $PSScriptRoot\..\..\helper.ps1
#endregion Header
#region Test Setup
$stigRuleToTest = @{
    Ensure       = 'absent'
    Extension    = @('.exe','.dll','.com','.bat','.csh')
    RuleCount    = 5
    CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

        Open the IIS 8.5 Manager.
        
        Click on the IIS 8.5 site.
        
        Under IIS, double-click the MIME Types icon.
        
        From the "Group by:" drop-down list, select "Content Type".
        
        From the list of extensions under "Application", verify MIME types for OS shell program extensions have been removed, to include at a minimum, the following extensions:
        
        .exe
        .dll
        .com
        .bat
        .csh

        If any OS shell MIME types are configured, this is a finding.'
}

$mimeTypeMapping = @{
    '.exe' = 'application/octet-stream'
    '.dll' = 'application/x-msdownload'
    '.bat' = 'application/x-bat'
    '.csh' = 'application/x-csh'
    '.com' = 'application/octet-stream'
}

$index = 0
#endregion Test Setup
#region Tests

Describe "MimeType Rule Conversion" {

    [xml] $StigRule = Get-TestStigRule -CheckContent $stigRuleToTest.CheckContent -XccdfTitle 'IIS'
    $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
    $StigRule.Save( $TestFile )
    $rules = ConvertFrom-StigXccdf -Path $TestFile

    It "Should retrun '$($stigRuleToTest.RuleCount))'" {
        $rules.count | Should be $stigRuleToTest.RuleCount
    }

    foreach ($rule in $rules)
    {
        It "Should return an MimeTypeRule Object" {
            $rule.GetType() | Should Be 'MimeTypeRule'
        }

        It "Should return Extension $($stigRuleToTest.Extension[$index])" {
            $rule.Extension | Should Be $stigRuleToTest.Extension[$index]
        }

        It "Should return MimeType '$( $mimeTypeMapping[$rule.Extension] )" {
            $rule.MimeType | Should Be $mimeTypeMapping[$rule.Extension]
        }

        It "Should return Ensure '$($stigRuleToTest.Ensure)'" {
            $rule.Ensure | Should Be $stigRuleToTest.Ensure
        }

        It 'Should Set the status to pass' {
            $rule.ConversionStatus | Should Be 'pass'
        }

        $index++
    }
}
#endregion Tests
