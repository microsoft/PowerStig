#region Header
. $PSScriptRoot\.Convert.Integration.Tests.Header.ps1
#endregion

# Import the base benchmark xml string data.
$BaseFileContent = Get-Content -Path "$PSScriptRoot\..\Data\sampleXccdf.xml.txt" -Encoding UTF8
$baseGroup = '
    <Group id="V-1">
    <title>Rule Title</title>
    <Rule id="SV-1234r1_rule" severity="high" weight="10.0">
    <check system="C-1234r2_chk">
    <check-content>STIG checks here. 
    </check-content>
    </check>
    </Rule>
    </Group>
'
<# 
    This is a sample xml entry that can be reused in individual registry describe and context 
    blocks and merged into the $BaseFileContent
#>

Describe "PowerStigConvert Module" {

    It "Should Import successfully" { 
        { Import-Module $modulePath } | Should Not Throw
    }
}

Describe 'ConvertFrom-StigXccdf' {

    It "Should have a synopsis" {
        [string] $Synopsis = (Get-Help ConvertFrom-StigXccdf).Synopsis
        $Synopsis | Should Not BeNullOrEmpty
    }

    Context 'Parse Registry Rule' {
        $group = '
            <Group id="V-1">
            <title>Registry Rule Title</title>
            <Rule id="SV-1234r1_rule" severity="high" weight="10.0">
            <check system="C-1234r2_chk">
            <check-content>If the following registry value does not exist or is not configured as specified, this is a finding:

            Registry Hive: {0} 
            Registry Path: {1}

            Value Name: {2}

            Value Type: {3}
            Value: {4}
            </check-content>
            </check>
            </Rule>
            </Group>
        '

        $RegistryHive = 'HKEY_LOCAL_MACHINE'
        $RegistryPath = '\System\CurrentControlSet\Control\'
        $ValueName = 'TestValueName'
        $ValueType = 'REG_DWORD'
        $Value = '1'

        $testGroup = $group -f $RegistryHive, $RegistryPath, $ValueName, $ValueType, $Value

        $TestFile = "TestDrive:\TextData.xml"
        
        $BaseFileContent -f 'Windows Server','','',$testGroup,'' | Out-File $TestFile
        $StigXccdf = ConvertFrom-StigXccdf -Path $TestFile

        It 'Should not throw an error' {
            {ConvertFrom-StigXccdf -Path $TestFile} | Should Not Throw
        }

        It 'Should return a RegistryRule Object' {
            #$StigXccdf[1] | Should Be ""
        }
    }

    Context 'Windows STIG' {

        $title = "Windows Server 2012 / 2012 R2 Member Server Security Technical Implementation Guide"
        $TestFile = "TestDrive:\TextData.xml"
        $BaseFileContent -f $title,'','',$baseGroup,'' | Out-File -FilePath $TestFile
        It "Should call Get-StigRules with 'Windows' in the title" {
            ConvertFrom-StigXccdf -Path $TestFile 
        }
    }
}

    # Get the lsit of public commands to ensure they are available
Describe 'ConvertTo-DscStigXml' {
        
    $TestFile = "TestDrive:\TextData.xml"
    $BaseFileContent -f '','','',$testGroup,'' | Out-File $TestFile

}

Describe 'Get-ConversionReport' {
        
    $TestFile = "TestDrive:\TextData.xml"
    $BaseFileContent -f '','','',$testGroup,'' | Out-File $TestFile


}
