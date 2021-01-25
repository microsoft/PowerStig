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

    It 'Should throw if a input for Verifier is not string' {
        {New-StigCheckList -MofFile 'test' -XccdfPath 'test' -OutputPath 'c:\test\test.ckl' -Verifier 1234} | Should -Throw
    }

    It 'Generate a checklist given correct parameters' {

        {
            $outputPath = Join-Path $Testdrive -ChildPath Checklist.ckl
            $xccdfPath = ((Get-ChildItem -Path $script:moduleRoot\StigData\Archive -Include *xccdf.xml -Recurse | Where-Object -Property Name -Match "Server_2019_MS")[1]).FullName
            New-StigChecklist -ReferenceConfiguration $mofTest -XccdfPath $xccdfPath -OutputPath $outputPath -Verifier "PowerSTIG User 12/17/2020"
        } | Should -Not -Throw
    }
}

Describe 'ConvertTo-ManualCheckListHashTable' {
    $xmlContentStringBuilder = [System.Text.StringBuilder]::new()
    [void] $xmlContentStringBuilder.AppendLine('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    [void] $xmlContentStringBuilder.AppendLine('<stigManualChecklistData>')
    [void] $xmlContentStringBuilder.AppendLine('<stigRuleData>')
    [void] $xmlContentStringBuilder.AppendLine('<STIG>U_Windows_Firewall_STIG_V1R7_Manual-xccdf.xml</STIG>')
    [void] $xmlContentStringBuilder.AppendLine('<ID>V-36440</ID>')
    [void] $xmlContentStringBuilder.AppendLine('<Status>NotAFinding</Status>')
    [void] $xmlContentStringBuilder.AppendLine('<Comments>Not Applicable</Comments>')
    [void] $xmlContentStringBuilder.AppendLine('<Details>This machine is not part of a domain, so this rule does not apply.</Details>')
    [void] $xmlContentStringBuilder.AppendLine('</stigRuleData>')
    [void] $xmlContentStringBuilder.AppendLine('</stigManualChecklistData>')

    Set-Content -Value $xmlContentStringBuilder.ToString() -Path (Join-Path -Path $TestDrive -ChildPath 'test.xml')

    $xmlHashTableResult = @{
        Comments = 'Not Applicable'
        Status   = 'NotAFinding'
        Details  = 'This machine is not part of a domain, so this rule does not apply.'
        ID       = 'V-36440'
        STIG     = 'U_Windows_Firewall_STIG_V1R7_Manual-xccdf.xml'
    }

    $psd1ContentStringBuilder = [System.Text.StringBuilder]::new()
    [void] $psd1ContentStringBuilder.AppendLine('@{')
    [void] $psd1ContentStringBuilder.AppendLine("`tVulID = `"V-36440`"")
    [void] $psd1ContentStringBuilder.AppendLine("`tStatus = `"NotAFinding`"")
    [void] $psd1ContentStringBuilder.AppendLine("`tComments = `"Not Applicable`"")
    [void] $psd1ContentStringBuilder.AppendLine('}')

    Set-Content -Value $psd1ContentStringBuilder.ToString() -Path (Join-Path -Path $TestDrive -ChildPath 'test.psd1')

    $psd1HashTableResult = $xmlHashTableResult.Clone()
    $psd1HashTableResult['Details'] = $psd1HashTableResult['Comments']


    It 'Should convert xml content into a hashtable' {
        $convertedXmlHashTable = ConvertTo-ManualCheckListHashTable -Path (Join-Path -Path $TestDrive -ChildPath 'test.xml') -XccdfPath 'C:\bogusXccdf.xml'
        $convertedXmlHashTable.Keys.Count | Should -Be $xmlHashTableResult.Keys.Count
        foreach ($key in $convertedXmlHashTable.Keys)
        {
            $convertedXmlHashTable[$key] | Should -Be $xmlHashTableResult[$key]
        }
    }

    It 'Should convert specifically formatted psd1 content into a hashtable' {
        Mock Get-StigXccdfFileName {return 'U_Windows_Firewall_STIG_V1R7_Manual-xccdf.xml'}
        $convertedPsd1HashTable = ConvertTo-ManualCheckListHashTable -Path (Join-Path -Path $TestDrive -ChildPath 'test.psd1') -XccdfPath 'C:\bogusXccdf.xml'
        $convertedPsd1HashTable.Keys.Count | Should -Be $psd1HashTableResult.Keys.Count
        foreach ($key in $convertedPsd1HashTable.Keys)
        {
            $convertedPsd1HashTable[$key] | Should -Be $psd1HashTableResult[$key]
        }
    }
}

Describe 'Get-StigXccdfFileName' {
    It 'Should return the correct Xccdf file name' {
        Mock Get-Content {return '<DISASTIG filename="U_Windows_Firewall_STIG_V1R7_Manual-xccdf.xml" fullversion="1.8"></DISASTIG>'}
        Mock Select-String {return [PSCustomObject]@{Path = 'C:\test\U_Windows_Firewall_STIG_V1R7_Manual-xccdf.xml'; Pattern = 'V-1111'}}
        $getStigXccdfFileNameResult = Get-StigXccdfFileName -VulnId 'V-1111' -XccdfPath 'C:\test\U_Windows_Firewall_STIG_V1R7_Manual-xccdf.xml'
        $getStigXccdfFileNameResult | Should -Be 'U_Windows_Firewall_STIG_V1R7_Manual-xccdf.xml'
    }
}
