#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

Describe 'New-StigCheckList' {

    configuration Example
    {
        param
        (
            [parameter()]
            [string]
            $NodeName = "localhost"
        )

        Import-DscResource -ModuleName PowerStig

        Node $NodeName
        {
            WindowsServer BaseLine
            {
                OsVersion   = "2019"
                OsRole      = "MS"
                SkipRuleType = "AccountPolicyRule","AuditPolicyRule","AuditSettingRule","DocumentRule","ManualRule","PermissionRule","SecurityOptionRule","UserRightRule","WindowsFeatureRule","ProcessMitigationRule","RegistryRule"
            }
        }
    }
    Example -OutputPath $TestDrive

    $mofTest = '{0}{1}' -f $TestDrive.fullname,"\localhost.mof"

    # Test parameter validity -OutputPath
    It 'Should throw if an invalid path is provided' {
        {New-StigCheckList -MofFile 'test' -XccdfPath 'test' -OutputPath 'c:\asdf'} | Should -Throw
    }

    It 'Should throw if the full path to a .ckl file is not provided' {
        {New-StigCheckList -MofFile 'test' -XccdfPath 'test' -OutputPath 'c:\test\test.ck'} | Should -Throw
    }

    # Test parameter -ManualCheckFile
    It 'Should throw if the full path to a ManualCheckFile is not valid' {
        {New-StigCheckList -MofFile 'test' -XccdfPath 'test' -ManualCheckFile 'broken' -OutputPath 'c:\test\test.ck'} | Should -Throw
    }

    # Test invalid parameter combinations
    It 'Should throw if an invalid combination of parameters for assessment is provided' {
        {New-StigChecklist -MofFile 'test' -DscResults 'test' -XccdfPath 'test' -OutputPath 'C:\test'} | should -Throw
    }

    It 'Should throw if an invalid combination of parameters for Xccdf validation is provided' {
        {New-StigCheckList -DscResult 'foo' -MofFile 'bar' -OutputPath 'C:\Test'} | Should -Throw
    }

    It 'Generate a checklist given correct parameters' {

        {
            $outputPath = Join-Path $Testdrive -ChildPath Checklist.ckl
            $xccdfPath = ((Get-ChildItem -Path $script:moduleRoot\StigData\Archive -Include *xccdf.xml -Recurse | Where-Object Name -match "Server_2019_MS")[1]).FullName
            New-StigChecklist -ReferenceConfiguration $mofTest -XccdfPath $xccdfPath -OutputPath $outputPath
        } | should -Not -Throw
    }
}

