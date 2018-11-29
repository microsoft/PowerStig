using module .\..\..\..\Module\Common\Common.psm1
. $PSScriptRoot\.tests.header.ps1
# Header
#region Enum Tests
<#
        a list of enums in the script that is used in a "burn down" manner. When an enum is processed
        it is removed from the list, The last test will be to verify that all of the enums have
        been tested
    #>
$enumDiscovered = New-Object System.Collections.ArrayList
# Select each line that starts with enum to count the number of enum's in the file

$enumListString = ( Get-Content $modulePath | Select-String "^Enum " )
# Add each enum that is found to the array
$enumListString | Foreach-Object { $enumDiscovered.add( ( $_ -split " " )[1].ToString().ToLower() ) | Out-Null }
# Get a count to to use in a final test to validate enum test coverage
[int] $enumTestCount = $enumDiscovered.Count

$enumTests = @{
    'Process' = 'auto|manual'
    'Status' = 'pass|warn|fail'
    'Severity' = 'low|medium|high'
    'Ensure' = 'Present|Absent'
    'RuleType' = 'AccountPolicyRule|AuditPolicyRule|DnsServerRootHintRule|DnsServerSettingRule|' +
    'DocumentRule|FileContentRule|GroupRule|IisLoggingRule|ManualRule|MimeTypeRule|' +
    'PermissionRule|ProcessMitigationRule|RegistryRule|SecurityOptionRule|ServiceRule|' +
    '|SkipRuleSqlScriptQueryRule|UserRightRule|WebConfigurationPropertyRule|' +
    '|WebAppPoolRuleWindowsFeatureRule|WinEventLogRule|WmiRule'
    'Technology' = 'Windows|SQL|Mozilla'
}

foreach ( $enum in $enumTests.GetEnumerator() )
{
    Describe "$($enum.Key) Enumeration" {

        $enumDiscovered.Remove( $enum.Key.tolower() )

        # Dump the status enum and verify it is the expected list
        # [process].GetEnumValues()
        $EnumValues = [enum]::GetValues($enum.Key)

        foreach ( $value in $EnumValues )
        {
            It "$value should exist" {
                $value | Should Match $enum.Value
            }
        }
    }
}

# Final test to validate all enums habve been tested
Describe 'Enum coverage' {

    It "Should have tested $enumTestCount enum's" {

        <#
            If this test is failing verify that the $enumList.Remove('enum') line is in the
            describe statemetn for the enum.
        #>
        ( $enumDiscovered.count - $enumTestCount ) * -1 | Should Be $enumTestCount
    }
}
#endregion Tests

#region Class
Describe 'RegularExpression Class' {

    Context 'Text Between Quotes' {

        It 'Should match string with double quotes' {
            'hello "this" test' -Match ([RegularExpression]::TextBetweenQuotes) | Should Be $true
        }

        It 'Should match string with single quotes' {
            "hello 'this' test" -Match ([RegularExpression]::TextBetweenQuotes) | Should Be $true
        }
    }


    Context 'TextBetweenParentheses string matches' {

        It 'Should match string inside parentheses' {
            '(text inside parentheses)' -Match ([RegularExpression]::TextBetweenParentheses) | Should Be $true
        }

        It 'Should NOT match text outside of parentheses' {
            'text outside ()' -Match ([RegularExpression]::TextBetweenParentheses) | Should Be $false
        }

        It 'Should NOT match text inside improperly written parentheses' {
            ')text(' -Match ([RegularExpression]::TextBetweenParentheses) | Should Be $false
        }

        It 'Should return text inside of parentheses when grabbing the last group' {
            $text = 'InsideOfParenthese'
            $unneededText = 'Unneeded text'

            $result = ( "$unneededText (" + $text + ") $unneededText" |
                    Select-String -Pattern ([RegularExpression]::TextBetweenParentheses) ).matches.groups[-1].Value

            $result | Should Be $text
        }
    }

}

#endregion

#region Data Tests


#endregion Tests
#region Helper Tests
Describe 'Get-AvailableId' {
    # Since this function uses a global variable, we need to make sure we don't step on anything.
    $resetglobalSettings = $false
    if ( $global:stigSettings )
    {
        [System.Collections.ArrayList] $globalSettings = $global:stigSettings
        $resetglobalSettings = $true
    }

    try
    {
        It 'Should add the next available letter to an Id' {
            $global:stigSettings = @(@{Id = 'V-1000'})
            Get-AvailableId -Id 'V-1000' | Should Be 'V-1000.a'
        }
    }
    finally
    {
        if ( $resetglobalSettings )
        {
            $global:stigSettings = $globalSettings
        }
    }
}
#endregion
#region xccdf Tests

Describe 'Get-StigXccdfBenchmarkContent' {

    InModuleScope Common {
        [xml]$xccdfTestContent = '<?xml version="1.0" encoding="utf-8"?><Benchmark><title>Test Title</title></Benchmark>'
        Mock -CommandName Test-Path -MockWith { return $true }
        Mock -CommandName Get-StigContentFromZip -MockWith { return $xccdfTestContent }
        Mock -CommandName Get-Content -MockWith { return $xccdfTestContent }

        It 'Should throw if the path is not found' {
            Mock -CommandName Test-Path -MockWith { return $false }
            { Get-StigXccdfBenchmarkContent -Path C:\Not\Found\file.xml } | Should Throw
        }

        It 'Should extract the xccdf from a ZIP' {
            Mock -CommandName Test-Path -MockWith { $true }
            $return = Get-StigXccdfBenchmarkContent -Path 'C:\download.zip'
            $return.title | Should Be 'Test Title'
        }
    }
}

Describe 'Get-StigContentFromZip' {

    InModuleScope Common {
        Mock -CommandName Expand-Archive -MockWith { return }
        Mock -CommandName Get-ChildItem -MockWith { return @{fullName = 'C:\file-Manual-xccdf.xml'} }
        Mock -CommandName Get-Content -MockWith { return 'Test XML'}
        Mock -CommandName Remove-Item -MockWith { return }

        It 'Should Extract the xccdf from the zip' {
            $return = Get-StigContentFromZip -Path C:\Path\to\file.zip
            $return | Should Be 'Test XML'
        }
    }
}

#endregion
#region Range Conversion Tests
<#
    These are sample values that have been identified in the STIG so far.
    Value:  1 or 2 = a Finding                      $i -notmatch "1|2"
    Value: 14 (or greater)                          $i -gt "14"
    Value: 30 (or less, but not 0)                  $i -le "30" -and $i -ne 0
    Value: 0x0000001e (30) (or less, but not 0)     $i -le "30" -and $i -gt 0
    Value: 0x0000001e (30) (or less, excluding 0)   $i -le "30" -and $i -gt 0
    Value: 90 (or less)                             $i -le "90"
    Value: 300000 (or less)                         $i -le "300000"
    Value:  3 (or less)                             $i -le "3"
    Value:  0x0000000f (15) (or less)               $i -le "15"
    Value: 0x00000384 (900) (or less)               $i -le "900"
    Value: 0x00008000 (32768) (or greater)          $i -ge "32768"
    Value: 0x00030000 (196608) (or greater)         $i -ge "196608"
#>

#region Tests
Describe 'Get-OrganizationValueTestString' {

    Mock Test-StringIsPositiveOr -ModuleName Common
    Mock Test-StringIsLessThan  -ModuleName Common
    Mock Test-StringIsLessThanOrEqual  -ModuleName Common
    Mock Test-StringIsLessThanButNot  -ModuleName Common
    Mock Test-StringIsLessThanOrEqualButNot  -ModuleName Common
    Mock Test-StringIsLessThanOrEqualExcluding -ModuleName Common
    Mock Test-StringIsGreaterThan -ModuleName Common
    Mock Test-StringIsGreaterThanOrEqual  -ModuleName Common
    Mock Test-StringIsGreaterThanButNot  -ModuleName Common
    Mock Test-StringIsGreaterThanOrEqualButNot -ModuleName Common
    Mock ConvertTo-OrTestString -ModuleName Common
    Mock ConvertTo-TestString -ModuleName Common

    It 'Should exist' {
        Get-Command -Name Get-OrganizationValueTestString | Should Not BeNullOrEmpty
    }

    Context 'NegativeOr' {
        Mock Test-StringIsNegativeOr -MockWith { return $true  } -ModuleName Common
        Mock Test-StringIsPositiveOr -MockWith { return $false } -ModuleName Common
        Mock ConvertTo-OrTestString { return 'ConvertedString' } -ModuleName Common -ParameterFilter {$string -eq "";
            $Operator -eq 'Equal'}
        It 'Should return the correct string' {
            Get-OrganizationValueTestString -String "1 or 2 = a Finding" | Should Be "ConvertedString"
        }

    }
}

Describe 'Get-TestStringTokenNumbers' {

    It 'Should exist' {
        Get-Command Get-TestStringTokenNumbers | Should Not BeNullOrEmpty
    }

    $Strings = @{
        'Greater than 30' = "30"
        '30 (or greater)' = "30"
        'Greater than 30 (but not 60)' = "30", "60"
        '30 (or greater, but not 60)' = "30", "60"
        'less than 30' = "30"
        '30 (or less)' = "30"
        "Less than 30 (but not 0)" = "30", "0"
        "0x0000001e (30) (or less, but not 0)" = "30", "0"
        "0x0000001e (30) (or less, excluding 0)" = "30", "0"
        "30 (or less, but not 0)" = "30", "0"
        "0x0000000f (15) (or less)" = "15"
        "0x00008000 (32768) (or greater)" = "32768"
    }

    foreach ($string in $strings.GetEnumerator())
    {
        It "Should return '$($string.Value)' when given '$($string.Key)'" {
            Get-TestStringTokenNumbers -String $string.Key | Should Be $string.Value
        }
    }
}

Describe 'Get-TestStringTokenList' {

    It 'Should exist' {
        Get-Command Get-TestStringTokenList | Should Not BeNullOrEmpty
    }

    Context 'CommandTokens ParameterSet' {
        $strings = @{
            'Greater than 30' = "greater than"
            '30 (or greater)' = "or greater"
            'Greater than 30 (but not 60)' = "greater than but not"
            '30 (or greater, but not 60)' = "or greater but not"
            'less than 30' = "less than"
            '30 (or less)' = "or less"
            "Less than 30 (but not 0)" = "less than but not"
            "30 (or less, but not 0)" = "or less but not"
            "0x0000001e (30) (or less, but not 0)" = "or less but not"
            "0x0000001e (30) (or less, excluding 0)" = "or less excluding"
            " 0x0000000f (15) (or less)" = "or less"
            "0x00008000 (32768) (or greater)" = "or greater"
        }

        foreach ($string in $strings.GetEnumerator())
        {
            It "Should return '$($string.Value)' when given '$($string.Key)'" {
                Get-TestStringTokenList -String $string.Key | Should Be $string.Value
            }
        }
    }

    Context 'StringTokens ParameterSet' {
        $strings = @{
            '"text1" is between quotes' = "text1"
            '"text1" and "text2" are between quotes' = @('text1', 'text2')
            '"text1" and "text2" but "text3" are between quotes' = @('text1', 'text2', 'text3')
        }

        foreach ($string in $strings.GetEnumerator())
        {
            It "Should return '$($string.Value)' when given '$($string.Key)'" {
                Get-TestStringTokenList -String $string.Key -StringTokens | Should Be $string.Value
            }
        }
    }
}

Describe 'ConvertTo-TestString' {
    $Strings = @{
        'Greater than 30' = "{0} -gt '30'"
        '30 (or greater)' = "{0} -ge '30'"
        'Greater than 30 (but not 60)' = "{0} -gt '30' -and {0} -lt '60'"
        '30 (or greater, but not 60)' = "{0} -ge '30' -and {0} -lt '60'"
        'less than 30' = "{0} -lt '30'"
        '30 (or less)' = "{0} -le '30'"
        "Less than 30 (but not 0)" = "{0} -lt '30' -and {0} -gt '0'"
        "30 (or less, but not 0)" = "{0} -le '30' -and {0} -gt '0'"
        "0x0000001e (30) (or less, but not 0)" = "{0} -le '30' -and {0} -gt '0'"
        "0x0000001e (30) (or less, excluding 0)" = "{0} -le '30' -and {0} -gt '0'"
        '0x00000384 (900) (or less, excluding "0" which is effectively disabled)' = "{0} -le '900' -and {0} -gt '0'"
        "  0x0000000f (15) (or less)" = "{0} -le '15'"
        "0x00008000 (32768) (or greater)" = "{0} -ge '32768'"
    }
    foreach ($string in $strings.GetEnumerator())
    {
        Mock -CommandName Get-TestStringTokenNumbers `
            -ParameterFilter {$string -eq $string.key} `
            -MockWith {return "30"}

        Mock -CommandName Get-TestStringTokenList `
            -ParameterFilter {$string -eq $string.key} `
            -MockWith {return "greater than"}

        It "Should return '$($string.Value)' when given '$($string.key)'" {
            ConvertTo-TestString -String $string.key | Should Be $string.Value
        }
    }
}
#endregion
#region OR
Describe 'Test-StringIsNegativeOr' {

    It 'Verifies the function exists' {
        Get-Command Test-StringIsNegativeOr | Should Not BeNullOrEmpty
    }

    $positiveMatchStrings = @(
        "1 or 2 = a Finding",
        "10 or 20 = a Finding",
        " 1 or 2 = a Finding",
        "1 or 2 = a Finding ",
        " 1 or 2 = a Finding ",
        "1  or  2  =  a  Finding",
        "1or2 = a Finding",
        "1or2=a Finding",
        "1or2=aFinding"
    )

    foreach ($positiveMatchString in $positiveMatchStrings)
    {
        It "Should be true with '$positiveMatchString'" {
            Test-StringIsNegativeOr -String $positiveMatchString | Should be $true
        }
    }

    $negativeMatchStrings = @(
        "1 or 2 = is not a Finding",
        "1 or 2",
        "2",
        "greater than 1"
    )

    foreach ($negativeMatchString in $negativeMatchStrings)
    {
        It "Should be false with '$negativeMatchString'" {
            Test-StringIsNegativeOr -String $negativeMatchString | Should be $false
        }
    }
}

Describe 'Test-StringIsPositiveOr' {

    It 'Verifies the function exists' {
        Get-Command Test-StringIsPositiveOr | Should Not BeNullOrEmpty
    }

    $positiveMatchStrings = @(
        "1 (Lock Workstation) or 2 (Force Logoff)",
        "1 ( Lock Workstation ) or 2 ( Force Logoff )",
        "1(Lock Workstation)or2(Force Logoff)",
        "1 (Lock) or 2 (Logoff)",
        "1 (Lock ) or 2 ( Logoff)",
        "1 ( Lock) or 2 (Logoff )",
        "1 (Lock Workstation) or 2 (Force Logoff)",
        "1 Lock Workstation or 2 Force Logoff",
        "1 'Lock Workstation' or 2 'Force Logoff'",
        "1 or 2",
        "1 or 2 = is not a Finding"
    )

    foreach ($positiveMatchString in $positiveMatchStrings)
    {
        It "Should be true with '$positiveMatchString'" {
            Test-StringIsPositiveOr -String $positiveMatchString | Should be $true
        }
    }

    $negativeMatchStrings = @(
        "2",
        "greater than 1",
        "Less than 10"
    )

    foreach ($negativeMatchString in $negativeMatchStrings)
    {
        It "Should be false with '$negativeMatchString'" {
            Test-StringIsPositiveOr -String $negativeMatchString | Should be $false
        }
    }
}

Describe 'ConvertTo-OrTestString' {

    It 'Should exist' {
        Get-Command ConvertTo-OrTestString | Should Not BeNullOrEmpty
    }

    Context 'NotMatch' {
        $operator = "NotMatch"
        $positiveMatchStrings = @{
            "1 or 2 = a Finding" = "{0} -notmatch '1|2'"
            "10 or 20 = a Finding" = "{0} -notmatch '10|20'"
        }

        foreach ($positiveMatchString in $positiveMatchStrings.GetEnumerator())
        {
            It "Should return '$($positiveMatchString.Value)' from '$($positiveMatchString.Key)'" {
                ConvertTo-OrTestString -String $positiveMatchString.Key -Operator $operator |
                    Should BeExactly $positiveMatchString.Value
            }
        }

        It 'Should throw an error if not a valid string' {
            {ConvertTo-NegativeOrTestString -String "Invalid" -Operator $operator} | Should Throw
        }
    }

    Context 'Match' {
        $operator = "Match"
        $positiveMatchStrings = @{
            "1 or 2 " = "{0} -match '1|2'"
            "10 or 20 " = "{0} -match '10|20'"
            "1 (Lock Workstation) or 2 (Force Logoff)" = "{0} -match '1|2'"
        }

        foreach ($positiveMatchString in $positiveMatchStrings.GetEnumerator())
        {
            It "Should return '$($positiveMatchString.Value)' from '$($positiveMatchString.Key)'" {
                ConvertTo-OrTestString -String $positiveMatchString.Key -Operator $operator |
                    Should BeExactly $positiveMatchString.Value
            }
        }

        It 'Should throw an error if not a valid string' {
            {ConvertTo-NegativeOrTestString -String "Invalid" -Operator $operator} | Should Throw
        }
    }
}
#endregion
#region Greater Than
Describe 'Test-StringIsGreaterThan' {
    $strings = @(
        'Greater than 30'
    )

    foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsGreaterThan -String $string | Should Be $true
        }
    }
}

Describe 'Test-StringIsGreaterThanOrEqual' {
    $strings = @(
        '30 (or greater)',
        ' 30 (or greater)',
        ' 30 (or greater) ',
        '0x00008000 (32768) (or greater)',
        ' 0x00008000 (32768) (or greater)',
        ' 0x00008000 (32768) (or greater) ',
        '0x0000000f (15) (or greater)',
        ' 0x0000000f (15) (or greater)',
        ' 0x0000000f (15) (or greater) '
    )

    foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsGreaterThanOrEqual -String $string | Should Be $true
        }
    }
}

Describe 'Test-StringIsGreaterThanButNot' {
    $strings = @(
        'Greater than 30 (but not 100)'
    )

    foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsGreaterThanButNot -String $string | Should Be $true
        }
    }
}

Describe 'Test-StringIsGreaterThanOrEqualButNot' {
    $strings = @(
        '30 (or greater, but not 100)'
    )

    foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsGreaterThanOrEqualButNot -String $string | Should Be $true
        }
    }
}
#endregion
#region Less Than
Describe 'Test-StringIsLessThan' {

    $strings = @(
        'less than 90',
        ' less than 90',
        ' less than 90 '
    )

    foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsLessThan -String $string | Should Be $true
        }
    }
}

Describe 'Test-StringIsLessThanOrEqual' {
    # Value: 90 (or less)                     $i -le "90"
    $strings = @(
        '90 (or less)',
        ' 90 (or less)',
        ' 90 (or less) ',
        '0x00000384 (900) (or less)',
        ' 0x00000384 (900) (or less)',
        ' 0x00000384 (900) (or less) ',
        '0x0000000f (15) (or less)',
        ' 0x0000000f (15) (or less)',
        ' 0x0000000f (15) (or less) '
    )

    foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsLessThanOrEqual -String $string | Should Be $true
        }
    }
}

Describe 'Test-StringIsLessThanButNot' {

    $strings = @(
        'less than 30 (but not 0)'
    )

    foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsLessThanButNot -String $string | Should Be $true
        }
    }
}

Describe 'Test-StringIsLessThanOrEqualButNot' {

    $strings = @(
        '30 (or less, but not 0)',
        ' 30 (or less, but not 0)',
        ' 30 (or less, but not 0) ',
        '3 (or less, but not 1)',
        ' 3 (or less, but not 1)',
        ' 3 (or less, but not 1) '
        '0x0000001e (30) (or less, but not 0)',
        ' 0x0000001e (30) (or less, but not 0)',
        ' 0x0000001e (30) (or less, but not 0) '
    )

    foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsLessThanOrEqualButNot -String $string | Should Be $true
        }
    }
}

Describe 'Test-StringIsLessThanOrEqualExcluding' {

    $strings = @(
        '0x0000001e (30) (or less, excluding 0)',
        ' 0x0000001e (30) (or less, excluding 0)'
    )

    foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsLessThanOrEqualExcluding -String $string | Should Be $true
        }
    }
}
#endregion
#region Multiple Values
Describe 'Test-StringIsMultipleValue' {

    $strings = @(
        'Possible values are NoSync, NTP, NT5DS, AllSync'
    )

    foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsMultipleValue -String $string | Should Be $true
        }
    }
}

Describe 'ConvertTo-MultipleValue' {
    $Strings = @{
        'Possible values are orange, lemon, cherry' = "'{0}' -match '^(orange|lemon|cherry)$'"
    }
    foreach ($string in $strings.GetEnumerator())
    {
        It "Should return '$($string.Value)' when given '$($string.key)'" {
            ConvertTo-MultipleValue -String $string.key | Should Be $string.Value
        }
    }
}
#endregion
#region Security Policy
Describe 'Get-SecurityPolicyString' {
    $checkStrings = @(
        @{
            checkContent = 'Verify the effective setting in Local Group Policy Editor.
            Run "gpedit.msc".

            Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Account Lockout Policy.

            If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.'
            match = '"Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.'
        },
        @{
            checkContent = 'Verify the effective setting in Local Group Policy Editor.

            Run "gpedit.msc".

            Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Password Policy.

            If the value for the "Maximum password age" is greater than "60" days, this is a finding.

            If the value is set to "0" (never expires), this is a finding.'
            match = '"Maximum password age" is greater than "60" days, this is a finding. or is set to "0" (never expires), this is a finding.'
        }
    )

    foreach ($checkString in $checkStrings)
    {
        It 'Should return the second string in quotes' {
            $checkContent = (Split-TestStrings -CheckContent $checkString.checkContent)
            Get-SecurityPolicyString -CheckContent $checkContent | Should Be $checkString.match
        }
    }
}
Describe 'Test-SecurityPolicyContainsRange' {
    $checkContent = 'Verify the effective setting in Local Group Policy Editor.
    Run "gpedit.msc".

    Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Account Lockout Policy.

    {0}'
    Context 'Match' {

        $strings = @(
            'If the "Reset account lockout counter after" value is less than "15" minutes, this is a finding.',
            'If the value for "Enforce password history" is less than "24" passwords remembered, this is a finding.',
            'If the "Account lockout threshold" is "0" or more than "3" attempts, this is a finding.',
            'If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.',
            'If the value for the "Minimum password length," is less than "14" characters, this is a finding.',
            'If the value for the "Minimum password age" is set to "0" days ("Password can be changed immediately."), this is a finding.',
            'If the value for the "Maximum password age" is greater than "60" days, this is a finding.  If the value is set to "0" (never expires), this is a finding.',
            'If the value for "Accounts: Rename administrator account" is not set to a value other than "Administrator", this is a finding.'
        )

        foreach ( $string in $strings )
        {
            It "Should return true from '$string'" {
                $checkContent = (Split-TestStrings -CheckContent ($checkContent -f $string))
                Test-SecurityPolicyContainsRange -CheckContent $checkContent| Should Be $true
            }
        }
    }

    Context 'Not Match' {

        $strings = @(
            'If the value for "Password must meet complexity requirements" is not set to "Enabled", this is a finding.',
            'If the value for "Store password using reversible encryption" is not set to "Disabled", this is a finding.',
            'If the "Account lockout duration" is not set to "0", requiring an administrator to unlock the account, this is a finding.'
        )

        foreach ( $string in $strings )
        {
            It "Should return false from '$string'" {
                $checkContent = (Split-TestStrings -CheckContent ($checkContent -f $string))
                $result = Test-SecurityPolicyContainsRange -CheckContent $checkContent
                $result | Should Be $false
            }
        }
    }
}

Describe 'Get-SecurityPolicyOrganizationValueTestString' {
    $checkContent = 'Verify the effective setting in Local Group Policy Editor.
    Run "gpedit.msc".

    Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Account Lockout Policy.

    {0}'
    $strings = @{
        'If the "Reset account lockout counter after" value is less than "15" minutes , this is a finding.' = "'{0}' -ge '15'";
        'If the value for the "Minimum password age" is set to "0" days ("Password can be changed immediately."), this is a finding.' = "'{0}' -ne '0'";
        'If the "Account lockout threshold" is "0" or more than "3" attempts, this is a finding.' = "'{0}' -le '3' -and '{0}' -ne '0'";
        'If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.' = "'{0}' -ge '15' -or '{0}' -eq '0'";
        'If the value for the "Maximum password age" is greater than "60" days, this is a finding.  If the value is set to "0" (never expires), this is a finding.' = "'{0}' -le '60' -and '{0}' -ne '0'"
    }

    foreach ($string in $strings.GetEnumerator())
    {
        It "Should return ($($string.Value)) from '$($string.Key)'" {
            $checkContent = (Split-TestStrings -CheckContent ($checkContent -f $string.Key))
            $result = Get-SecurityPolicyOrganizationValueTestString -CheckContent $checkContent
            $result | Should Be $string.Value
        }
    }

    It 'Should throw if a match is not found' {
        {Get-SecurityPolicyOrganizationValueTestString -CheckContent 'no match'} | Should Throw
    }
}
#endregion
#endregion
