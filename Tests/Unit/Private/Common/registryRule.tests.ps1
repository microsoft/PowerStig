#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.psm1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module $modulePath -Force
#endregion
#region Test Setup
$checkContent = @'
If the following registry value does not exist or is not configured as specified, this is a finding:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \Software\Microsoft\Windows\CurrentVersion\Policies\System\

Value Name: ShutdownWithoutLogon

Value Type: REG_DWORD
Value: 0
'@
#endregion
#region Tests
Describe 'ConvertTo-RegistryRule' {

    $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
    $rule = ConvertTo-RegistryRule -StigRule $stigRule

    It "Should return an RegistryRule object" {
        $rule.GetType() | Should Be 'RegistryRule'
    }
}

Describe "Get-RegistryKey" {

    Context 'Windows STIG' {

        $hive = "HKEY_LOCAL_MACHINE"
        $path = "\Path\To\Value"
        $checkContent = "Registry Hive: $hive" +
        "Registry Path:  $path"

        Mock Test-SingleLineRegistryRule {return $false} -ModuleName RegistryRuleClass -Verifiable
        Mock Get-RegistryHiveFromWindowsStig {return "HKEY_LOCAL_MACHINE"} -ModuleName RegistryRuleClass
        Mock Get-RegistryPathFromWindowsStig {return "\Path\To\Value"} -ModuleName RegistryRuleClass

        It 'Should return the correct path' {
            $correctPath = Get-RegistryKey -CheckContent $checkContent
            $correctPath | Should Be "$hive$path"
            Assert-VerifiableMocks
        }
    }

    Context 'Office STIG' {

        $fullPath = "HKCU\Path\To\Value"
        $checkContent = ("",
            "$fullPath",
            "",
            "Criteria: If the value XL4Workbooks is REG_DWORD = 2, this is not a finding.")

        Mock Get-SingleLineRegistryPath {return "HKCU\Path\To\Value"} -ModuleName RegistryRuleClass -Verifiable
        Mock Test-SingleLineRegistryRule {return $true} -ModuleName RegistryRuleClass -Verifiable

        It 'Should return the correct HKCU path' {
            Get-RegistryKey -CheckContent $checkContent | Should Be $fullPath
            Assert-VerifiableMocks
        }
        Mock Get-SingleLineRegistryPath {return "HKLM\Path\To\Value"} -ModuleName RegistryRuleClass -Verifiable
        $fullPath = "HKLM\Path\To\Value"
        $checkContent = ("",
            "$fullPath",
            "",
            "Criteria: If the value XL4Workbooks is REG_DWORD = 2, this is not a finding.")

        It 'Should return the correct HKLM path' {
            Get-RegistryKey -CheckContent $checkContent | Should Be $fullPath
        }
    }
}

Describe "Get-RegistryHiveFromWindowsStig" {

    $goodStrings = @(
        "Registry Hive:{0}", "Registry Hive: {0}",
        ' Registry Hive: {0}', ' Registry Hive:  {0}',
        'Hive:{0}', 'Hive: {0}', 'Hive:  {0}',
        ' Hive:{0}', ' Hive:{0}', ' Hive:  {0}'
    )

    foreach ($string in $goodStrings)
    {
        $hive = 'HKEY_LOCAL_MACHINE'
        $checkContent = $string -f $hive

        It " Should return '$hive' from '$checkContent'" {
            Get-RegistryHiveFromWindowsStig -CheckContent $checkContent | Should Be $hive
        }
    }

    It " Should throw an error when a hive is not found" {
        $checkContent = "Registry Hive: HKEYLM \nRegistry Path: \Path" -split "\\n"
        {Get-RegistryHiveFromWindowsStig -CheckContent $checkContent} | Should Throw
    }
}

Describe "Get-RegistryPathFromWindowsStig" {

    # a list of invalid registry key formats to validate the regex
    $pathToExtract = 'SYSTEM\CurrentControlSet'
    $goodStrings = @(
        "Registry Path: \$pathToExtract\" , " Registry Path: $pathToExtract\",
        "Registry Path:  \$pathToExtract\", " Registry Path:  $pathToExtract\",
        "Path: \$pathToExtract\", " Path: $pathToExtract\", " Path:  $pathToExtract\",
        "Path: \$pathToExtract" , " Path: $pathToExtract" , " Path:  $pathToExtract",
        "Subkey: \$pathToExtract", " Subkey: $pathToExtract", " Subkey:  $pathToExtract")

    foreach ( $path in $goodStrings )
    {
        It "Should return '\$pathToExtract' from '$path'" {
            Get-RegistryPathFromWindowsStig -CheckContent $path | Should Be "\$pathToExtract"
        }
    }
    # test for an edge case where the intern at DISA added a space between 'SOFTWARE\ Polices'

    It "Should return path with typo and formated correctly" {
        $typoString = 'Registry Path: \SOFTWARE\ Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
        $expected = '\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
        $result = Get-RegistryPathFromWindowsStig -CheckContent $typoString

        $result | Should Be $expected
    }
    #  Fuzz testing the regex
    $badStrings = @(
        'Registry Path: SYSTEM', 'Registry Path: \SYSTEM', 'Registry Path: \SYSTEM\',
        "Path: SYSTEM", " Path: SYSTEM", "Path: \SYSTEM", "Path:  \SYSTEM", "Path: \SYSTEM\",
        "Subkey: SYSTEM", "Subkey:  SYSTEM", "Subkey: \SYSTEM", "Subkey: \SYSTEM\")

    foreach ( $path in $badStrings )
    {
        It "Should throw an error when given '$path'" {
            #Get-RegistryPathFromWindowsStig -CheckContent $path
            {Get-RegistryPathFromWindowsStig -CheckContent $path} | Should Throw
        }
    }
}
#region #########################################   Registry Type   ########################################
Describe "Get-RegistryValueType" {
    # A list of the registry types in the STIG(key) to DSC(value) format
    # this is a seperate list to detect changes in the script
    $registryTypes = [ordered] @{
        'REG_SZ'        = 'String'
        'REG_BINARY'    = 'Binary'
        'REG_DWORD'     = 'Dword'
        'REG_QWORD'     = 'Qword'
        'REG_MULTI_SZ'  = 'MultiString'
        'REG_EXPAND_SZ' = 'ExpandableString'
    }

    Context 'Windows STIG' {
        Mock Test-SingleLineStigFormat {return $false} -ModuleName RegistryRuleClass
        Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_SZ'} -ModuleName RegistryRuleClass -Verifiable

        It "Should call Get-RegistryValueTypeFromWindowsStig when a Windows STIG is given" {
            Get-RegistryValueType -CheckContent "Type: REG_SZ" | Out-Null
            Assert-VerifiableMocks
        }

        foreach ( $item in $registryTypes.GetEnumerator() )
        {
            [string] $registryTypeFromSTIG = $item.Key
            [string] $registryTypeForDSC = $item.Value

            It "Should accept '$registryTypeFromSTIG' and return '$registryTypeForDSC'" {
                Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_SZ'} -ModuleName RegistryRuleClass -ParameterFilter {$CheckContent -eq 'Type: REG_SZ'}
                Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_BINARY'} -ModuleName RegistryRuleClass -ParameterFilter {$CheckContent -match 'REG_BINARY'}
                Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_DWORD'} -ModuleName RegistryRuleClass -ParameterFilter {$CheckContent -match 'REG_DWORD'}
                Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_QWORD'} -ModuleName RegistryRuleClass -ParameterFilter {$CheckContent -match 'REG_QWORD'}
                Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_MULTI_SZ'} -ModuleName RegistryRuleClass -ParameterFilter {$CheckContent -match 'REG_MULTI_SZ'}
                Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_EXPAND_SZ'} -ModuleName RegistryRuleClass -ParameterFilter {$CheckContent -match 'REG_EXPAND_SZ'}

                $RegistryValueType = Get-RegistryValueType -CheckContent "Type: $($item.Key)"
                $RegistryValueType | Should Be $registryTypeForDSC
            }
        }

        It "Should return 'null' with invalid registry type" {
            Mock Get-RegistryValueTypeFromWindowsStig {return 'Invalid'} -ModuleName RegistryRuleClass
            Get-RegistryValueType -CheckContent 'Mocked data' | Should Be $null
        }

    }

    Context 'Office STIG' {
        function Get-RegistryValueTypeFromSingleLineStig {}
        Mock Test-SingleLineStigFormat {return $true} -ModuleName RegistryRuleClass
        Mock Get-RegistryValueTypeFromSingleLineStig {return 'REG_SZ'} -ModuleName RegistryRuleClass -Verifiable

        It "Should call Get-RegistryValueTypeFromSingleLineStig when an Office STIG is given" {
            Get-RegistryValueType -CheckContent "Type: REG_SZ" | Out-Null
            Assert-VerifiableMocks
        }

    }
}

Describe "Get-RegistryValueTypeFromWindowsStig" {

    $checkContent = "Type: REG_SZ"
    $RegistryValueType = Get-RegistryValueTypeFromWindowsStig -CheckContent $checkContent

    It "Should return 'REG_Type' from '$checkContent'" {
        $RegistryValueType | Should Be 'REG_SZ'
    }
}
#endregion
#region #########################################   Registry Name   ########################################
Describe "Get-RegistryValueName" {

    $valueName = 'ValueName'

    Context 'Windows STIG' {

        Mock Test-SingleLineStigFormat {return $false} -ModuleName RegistryRuleClass

        It "Should return ValueName" {
            Mock Get-RegistryValueNameFromWindowsStig {return 'ValueName'} -ModuleName RegistryRuleClass
            $RegistryValueName = Get-RegistryValueName -CheckContent "Name: $valueName"
            $RegistryValueName | Should Be 'ValueName'
        }
    }

    Context 'Office STIG' {
        Mock Test-SingleLineStigFormat {return $true} -ModuleName RegistryRuleClass

        $checkContent = "Criteria: If the value $valueName is REG_Type = 2, this is not a finding."

        It "Should return ValueName" {
            Mock Get-RegistryValueNameFromSingleLineStig {return 'ValueName' } -ModuleName RegistryRuleClass
            $RegistryValueName = Get-RegistryValueName -CheckContent $checkContent
            $RegistryValueName | Should Be $valueName
        }
    }
}

Describe "Get-RegistryValueNameFromWindowsStig" {
    # Test different number of trailing and leading spaces to verify the match
    $stringsToTest = @(
        'Value Name:',
        ' Value Name:',
        ' Value Name: ',
        'Value Name:  '
    )

    foreach ($string in $stringsToTest)
    {
        $valueName = 'ValueName'
        $checkContent = "$string $valueName"
        It "Should return '$valueName' from '$checkContent'" {
            Get-RegistryValueNameFromWindowsStig -CheckContent $checkContent | Should Be $valueName
        }
    }
}
#endregion
#region #########################################   Registry Data   ########################################
Describe "Get-RegistryValueData" {

    Context 'Windows STIG' {

        Mock Test-SingleLineStigFormat {return $false} -ModuleName RegistryRuleClass
        Mock Get-RegistryValueDataFromWindowsStig {return ""} -ModuleName RegistryRuleClass -Verifiable
        It 'Should call the Windows code path when not an office registry format' {
            Get-RegistryValueData -CheckContent "Value: 1"
            Assert-VerifiableMocks
        }
    }

    Context 'Office STIG' {
        Mock Test-SingleLineStigFormat {return $true} -ModuleName RegistryRuleClass
        Mock Get-RegistryValueDataFromSingleStig -ModuleName RegistryRuleClass -Verifiable
        It 'Should call the Office code path with an office registry format' {
            Get-RegistryValueData -CheckContent "Criteria: 1"
            Assert-VerifiableMocks
        }
    }
}

Describe "Get-RegistryValueDataFromWindowsStig" {
    <#
        There are a lot of different string formats that have been found in the registry data
        so replicas of each pattern seen to data is represented below with the expected
        output. If new patterns are disovered, add them here to expand the test coverage.
    #>
    $testValues = @{

        # Integers with different leading and trailing spaces
        'Value: 1 (Enabled)'                           = '1 (Enabled)'
        'Value: 1'                                     = '1'
        'Value: 1 '                                    = '1'
        'Value:1'                                      = '1'
        'Value:1 '                                     = '1'
        'Value: 10'                                    = '10'
        'Value: 10 '                                   = '10'
        'Value:10'                                     = '10'
        'Value:10 '                                    = '10'
        'Value: 196608'                                = '196608'
        'Value: 32768'                                 = '32768'
        'Value: 4 (Prompt for consent)'                = '4 (Prompt for consent)'

        # Hex values
        'Value: 0x0000000a (10)'                       = '0x0000000a (10)'
        'Value: 0x20080000 (537395200)'                = '0x20080000 (537395200)'

        'Value: 1 or 2 = a Finding'                    = '1 or 2 = a Finding'

        # Integers with a range
        'Value:  3 (or less)'                          = '3 (or less)'
        'Value: 5 (or less)'                           = '5 (or less)'
        'Value: 300000 (or less)'                      = '300000 (or less)'
        'Value: 30 (or less, but not 0)'               = '30 (or less, but not 0)'
        'Value: 14 (or greater)'                       = '14 (or greater)'

        # Hex values with a range
        'Value: 0x00000384 (900) (or less)'            = '0x00000384 (900) (or less)'
        'Value: 0x000004b0 (1200) or less'             = '0x000004b0 (1200) or less'
        'Value: 0x000dbba0 (900000) or less but not 0' = '0x000dbba0 (900000) or less but not 0'
        'Value: 0x00000032 (50) (or greater)'          = '0x00000032 (50) (or greater)'
    }

    foreach ($testValue in $testValues.GetEnumerator())
    {
        It "Should return '$($testValue.value)' from '$($testValue.key)'" {
            $RegistryValueDataFromWindowsStig = Get-RegistryValueDataFromWindowsStig -CheckContent $testValue.key
            $RegistryValueDataFromWindowsStig | Should Be $testValue.value
        }
    }
}

#endregion
Describe 'Test-RegistryValueDataIsBlank' {

    It "Should return True when given '(Blank)'" {
        Test-RegistryValueDataIsBlank -ValueDataString "(Blank)" | Should BeExactly $true
    }

    It "Should return False when not given '(Blank)'" {
        Test-RegistryValueDataIsBlank -ValueDataString "Anything else" | Should BeExactly $false
    }
}

Describe 'Test-RegistryValueDataIsEnabledOrDisabled' {

    $passTests = 'Enabled', 'Enable', 'Disabled', 'Disable'
    foreach ($test in $passTests)
    {
        It "Should return True when given '$test'" {
            Test-RegistryValueDataIsEnabledOrDisabled -ValueDataString $test | Should BeExactly $true
        }
    }
    It "Should return False when not given enabled ro disabled" {
        Test-RegistryValueDataIsEnabledOrDisabled -ValueDataString "Anything else" | Should BeExactly $false
    }
}

Describe 'Get-ValidEnabledOrDisabled' {

    Context 'Valid Dword' {

        Mock Test-IsValidDword {return $false} -ModuleName RegistryRuleClass
        Mock ConvertTo-ValidDword {return '1'} -ModuleName RegistryRuleClass -ParameterFilter {$valueData -match 'Enable'}
        Mock ConvertTo-ValidDword {return '0'} -ModuleName RegistryRuleClass -ParameterFilter {$valueData -match 'Disable'}

        It "Should Convert Enable into 1 with Type Dword" {
            Get-ValidEnabledOrDisabled -ValueType 'Dword' -ValueData "Enabled" | Should Be "1"
        }

        It "Should Convert Disabled into 1 with Type Dword" {
            Get-ValidEnabledOrDisabled -ValueType 'Dword' -ValueData "Disable" | Should Be "0"
        }
    }

    Context 'Invalid Dword' {

        Mock Test-IsValidDword {return $true} -ModuleName RegistryRuleClass

        It "Should return Enable when not a Dword" {
            Get-ValidEnabledOrDisabled -ValueType 'Dword' -ValueData "Enabled" | Should Be "Enabled"
        }

        It "Should return Disable when not a Dword" {
            Get-ValidEnabledOrDisabled -ValueType 'Dword' -ValueData "Disable" | Should Be "Disable"
        }
    }
}

Describe 'Hex Code Tasks' {
    $testValues = @{
        'Value: 0x00000384 (900) (or less)'            = '900'
        'Value: 0x000004b0 (1200) or less'             = '1200'
        'Value: 0x000dbba0 (900000) or less but not 0' = '900000'
        'Value: 0x00000032 (50) (or greater)'          = '50'
    }

    Context 'Test-RegistryValueDataIsHexCode' {
        foreach ($testValue in $testValues.GetEnumerator())
        {
            It "Should return True when given '$($testValue.key)'" {
                Test-RegistryValueDataIsHexCode -ValueDataString $testValue.key | Should Be $true
            }
        }

        It "Should return False when not given a hex code" {
            Test-RegistryValueDataIsHexCode -ValueDataString "Anything else" | Should Be $false
        }
    }

    Context 'Get-IntegerFromHex' {

        It "Should thow an error if a hex code is not found" {
            {Get-IntegerFromHex -ValueDataString 'No Hex code here'} | Should Throw
        }

        Foreach ($testValue in $testValues.GetEnumerator())
        {
            It "Should return '$($testValue.value)' from '$($testValue.key)'" {
                Get-IntegerFromHex -ValueDataString $testValue.Key | Should Be $testValue.Value
            }
        }
    }
}

Describe 'Integer tasks' {

    $testValues = [ordered] @{

        # Integers with different leading and trailing spaces
        'Value: 1 (Enabled)'            = '1'
        'Value: 1'                      = '1'
        'Value: 1 '                     = '1'
        'Value:1'                       = '1'
        'Value:1 '                      = '1'
        'Value: 10'                     = '10'
        'Value: 10 '                    = '10'
        'Value:10'                      = '10'
        'Value:10 '                     = '10'
        'Value: 196608'                 = '196608'
        'Value: 32768'                  = '32768'
        'Value: 4 (Prompt for consent)' = '4'
    }

    Context 'Test-RegistryValueDataIsInteger' {

        foreach ($test in $testValues.GetEnumerator())
        {
            It "Should return True when given '$($test.Key)'" {
                Test-RegistryValueDataIsInteger -ValueDataString $test.key | Should BeExactly $true
            }
        }

        It "Should return False when not given a hex code" {
            Test-RegistryValueDataIsInteger -ValueDataString "Anything else" | Should BeExactly $false
        }
    }

    Context 'Get-NumberFromString' {

        It "Should thow an error if a integer is not found" {
            {Get-NumberFromString -ValueDataString 'No Integers here'} | Should Throw
        }

        Foreach ($string in $testValues.GetEnumerator())
        {
            It "Should return '$($string.value)' from '$($string.key)'" {
                Get-NumberFromString -ValueDataString $string.Key | Should Be $String.Value
            }
        }
    }
}

Describe 'Test-RegistryValueDataContainsRange' {

    Context 'Matches' {
        $rangeStrings = @(
            'Value: 1 or 2 = a Finding',
            'Value:  3 (or less)',
            'Value: 300000 (or less)',
            'Value: 30 (or less, but not 0)',
            'Value: 0x000dbba0 (900000) or less but not 0',
            'Value: Possible values are NoSync,NTP,NT5DS, AllSync'
        )

        foreach ($string in $rangeStrings)
        {
            It "Should return true when given '$string'" {
                $containsRange = Test-RegistryValueDataContainsRange -ValueDataString $string
                $containsRange | Should Be $true
            }
        }
    }

    Context 'Non Matches' {
        $rangeStrings = @(
            'Value: (Blank)',
            'Value: Enabled',
            'Value: Disabled',
            'Value: 0x0000000a (10)',
            'Value: 10'
        )

        foreach ($string in $rangeStrings)
        {
            It "Should return false when given '$string'" {
                $containsRange = Test-RegistryValueDataContainsRange -ValueDataString $string
                $containsRange | Should Be $false
            }
        }
    }
}

Describe 'Format-MultiStringRegistryData' {

    It "Should return a multi line string from 'One Two Three'" {
        $MultiStringRegistryData = Format-MultiStringRegistryData -ValueDataString "One Two Three"
        ($MultiStringRegistryData -split ";")[0] | Should Be "One"
        ($MultiStringRegistryData -split ";")[1] | Should Be "Two"
        ($MultiStringRegistryData -split ";")[2] | Should Be "Three"
    }

    It "Should return a multi line string from 'Four, Five, Six'" {
        $MultiStringRegistryData = Format-MultiStringRegistryData -ValueDataString "Four, Five, Six"
        ($MultiStringRegistryData -split ";")[0] | Should Be "Four"
        ($MultiStringRegistryData -split ";")[1] | Should Be "Five"
        ($MultiStringRegistryData -split ";")[2] | Should Be "Six"
    }
}

Describe 'Get-MultiValueRegistryStringData' {

    $checkStrings = "Value: see below

System\Path\One
System\Path\Two
Software\Path\Three

Legitimate applications may add entries to this registry value."
    $MultiValueRegistryStringData = Get-MultiValueRegistryStringData -CheckStrings $checkStrings

    It "Should return a string of semicolon delimited values." {
        ($MultiValueRegistryStringData -split ";")[0] | Should Be "System\Path\One"
    }

    It "Should return a string of semicolon delimited values." {
        ($MultiValueRegistryStringData -split ";")[1] | Should Be "System\Path\Two"
    }

    It "Should return a string of semicolon delimited values." {
        ($MultiValueRegistryStringData -split ";")[2] | Should Be "Software\Path\Three"
    }
}

Describe "Test-IsValidDword" {

    It "Should return $true when given an integer '3'" {
        Test-IsValidDword -ValueData "3" | Should Be $true
    }

    It "Should return $false when given a string 'Three'" {
        Test-IsValidDword -ValueData "Three" | Should Be $false
    }
}

Describe "ConvertTo-ValidDword" {

    $testValues = [ordered] @{

        # Integers with different leading and trailing spaces
        '1 (Enabled)'  = '1'
        'Enabled'      = '1'
        '0 (Disabled)' = '0'
        'Disabled'     = '0'
    }

    Foreach ($testValue in $testValues.GetEnumerator())
    {
        It "Should return '$($testValue.value)' when given '$($testValue.key)'" {
            ConvertTo-ValidDword -ValueData $testValue.key | Should Be $testValue.value
        }
    }

    It "Should throw an error when given anything but Enabled|Disable" {
        {ConvertTo-ValidDword -ValueData 'anything'} | Should Throw
    }
}

Describe 'Range value detection and return data' {

    <#
        See message * below

        Value: see below

                   System\CurrentControlSet\Control\ProductOptions
                   System\CurrentControlSet\Control\Server Applications
                   Software\Microsoft\Windows NT\CurrentVersion

        Value: see below

                   Software\Microsoft\OLAP Server
                   Software\Microsoft\Windows NT\CurrentVersion\Perflib
                   Software\Microsoft\Windows NT\CurrentVersion\Print
                   Software\Microsoft\Windows NT\CurrentVersion\Windows
                   System\CurrentControlSet\Control\ContentIndex
                   System\CurrentControlSet\Control\Print\Printers
                   System\CurrentControlSet\Control\Terminal Server
                   System\CurrentControlSet\Control\Terminal Server\UserConfig
                   System\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration
                   System\CurrentControlSet\Services\Eventlog
                   System\CurrentControlSet\Services\Sysmonlog
    #>

    Context 'Multi String Value' {

    }

    Context 'Multiple registry entries per SITG Id' {

    }
}

$multipleRegistryHiveString = "This applies to a server

If the following registry values are not configured as specified, this is a finding:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \Path\ToTheFirstValue\To\Set\

Value Name: SettingOneName

Type: REG_SZ
Value: ValueOne

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \Path\ToTheSecondValue\To\Set\

Value Name: SettingTwoName

Type: REG_DWORD
Value: ValueTwo"

$multipleRegistryPathString = "Determine if the setting is correct.

If they are not configured as specified, this is a finding.

Registry Hive: HKEY_LOCAL_MACHINE

Registry Path: \Path\ToTheFirstValue\To\Set\
Value Name: SettingOneName
Type: REG_SZ
Value: ValueOne

Registry Path: \Path\ToTheSecondValue\To\Set\
Value Name: SettingTwoName
Type: REG_DWORD
Value: ValueTwo

If it is not enabled and no alternate tool is enabled, this is a finding."

$multipleRegistryValueString = 'Review the following registry values:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \Path\ToTheFirstValue\To\Set\

Value Name: SettingOneName
Type: REG_SZ
Value: ValueOne

and

Value Name: SettingTwoName
Type: REG_DWORD
Value: ValueTwo'

$singleRegistryString = "If the following registry value does not exist or is not configured as specified, this is a finding:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \Path\ToTheFirstValue\To\Set\

Value Name: SettingOneName

Value Type: REG_SZ
Value: ValueOne"
Describe 'Test-MultipleRegistryEntries' {

    foreach ($checkContent in @($multipleRegistryHiveString, $multipleRegistryPathString, $multipleRegistryValueString))
    {
        It "Should return $true when multiple registry settings are found" {
            $hasMultipleEntries = Test-MultipleRegistryEntries -CheckContent ($checkContent -split "\n")
            $hasMultipleEntries | Should Be $true
        }
    }

    It "Should return $false when multiple registry settings are not found" {
        $hasMultipleEntries = Test-MultipleRegistryEntries -CheckContent ($singleRegistryString -split "\n")
        $hasMultipleEntries | Should Be $false
    }
}

Describe 'Split-MultipleRegistryEntries' {

    Context 'Multiple Hives' {
        $registryEntries = Split-MultipleRegistryEntries -CheckContent ($multipleRegistryHiveString -split "\n")

        It "Should not return the second registry entry in the first object" {
            $registryEntries[0] -notmatch '\\Path\\ToTheSecondValue\\To\\Set\\' | Should Be $true
            $registryEntries[0] -notmatch 'SettingTwoName' | Should Be $true
            $registryEntries[0] -notmatch 'REG_DWORD' | Should Be $true
            $registryEntries[0] -notmatch 'ValueTwo' | Should Be $true
        }

        It "Should not return the first registry entry in the second object" {
            $registryEntries[1] -notmatch '\\Path\\ToTheFirstalue\\To\\Set\\' | Should Be $true
            $registryEntries[1] -notmatch 'SettingOneName' | Should Be $true
            $registryEntries[1] -notmatch 'REG_SZ' | Should Be $true
            $registryEntries[1] -notmatch 'ValueOne' | Should Be $true
        }
    }

    Context 'Multiple Paths' {
        $registryEntries = Split-MultipleRegistryEntries -CheckContent ( $multipleRegistryPathString -split "\n")

        It "Should not return the second registry entry in the first object, but have the same Hive" {
            $registryEntries[0] -match 'HKEY_LOCAL_MACHINE' | Should Be $true
            $registryEntries[0] -notmatch '\\Path\\ToTheSecondValue\\To\\Set\\' | Should Be $true
            $registryEntries[0] -notmatch 'SettingTwoName' | Should Be $true
            $registryEntries[0] -notmatch 'REG_DWORD' | Should Be $true
            $registryEntries[0] -notmatch 'ValueTwo' | Should Be $true
        }

        It "Should not return the first registry entry in the second object, but have the same Hive" {
            $registryEntries[1] -match 'HKEY_LOCAL_MACHINE' | Should Be $true
            $registryEntries[1] -notmatch '\\Path\\ToTheFirstalue\\To\\Set\\' | Should Be $true
            $registryEntries[1] -notmatch 'SettingOneName' | Should Be $true
            $registryEntries[1] -notmatch 'REG_SZ' | Should Be $true
            $registryEntries[1] -notmatch 'ValueOne' | Should Be $true
        }
    }

    Context 'Multiple Values' {
        $registryEntries = Split-MultipleRegistryEntries -CheckContent ( $multipleRegistryValueString -split "\n")

        It "Should not return the second registry entry in the first object, but have the same hive and path" {
            $registryEntries[0] -match 'HKEY_LOCAL_MACHINE' | Should Be $true
            $registryEntries[0] -match '\\Path\\ToTheFirstValue\\To\\Set\\' | Should Be $true
            $registryEntries[0] -notmatch 'SettingTwoName' | Should Be $true
            $registryEntries[0] -notmatch 'REG_DWORD' | Should Be $true
            $registryEntries[0] -notmatch 'ValueTwo' | Should Be $true
        }

        It "Should not return the first registry entry in the second object, but have the same hive and path" {
            $registryEntries[1] -match 'HKEY_LOCAL_MACHINE' | Should Be $true
            $registryEntries[1] -match '\\Path\\ToTheFirstValue\\To\\Set\\' | Should Be $true
            $registryEntries[1] -notmatch 'SettingOneName' | Should Be $true
            $registryEntries[1] -notmatch 'REG_SZ' | Should Be $true
            $registryEntries[1] -notmatch 'ValueOne' | Should Be $true
        }
    }
}
#endregion
