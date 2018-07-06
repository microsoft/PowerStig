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
<#
    These are sample values that have been identified in the STIG so far.
    Value:  1 or 2 = a Finding              $i -notmatch "1|2"
    Value: 14 (or greater)                  $i -gt "14"
    Value: 30 (or less, but not 0)          $i -le "30" -and $i -ne 0
    Value: 90 (or less)                     $i -le "90"
    Value: 300000 (or less)                 $i -le "300000"
    Value:  3 (or less)                     $i -le "3"
    Value:  0x0000000f (15) (or less)       $i -le "15"
    Value: 0x00000384 (900) (or less)       $i -le "900"
    Value: 0x00008000 (32768) (or greater)  $i -ge "32768"
    Value: 0x00030000 (196608) (or greater) $i -ge "196608"
#>
#region Tests
Describe 'Get-OrganizationValueTestString' {

    Mock Test-StringIsPositiveOr -ModuleName Convert.Common.RangeConversion
    Mock Test-StringIsLessThan  -ModuleName Convert.Common.RangeConversion
    Mock Test-StringIsLessThanOrEqual  -ModuleName Convert.Common.RangeConversion
    Mock Test-StringIsLessThanButNot  -ModuleName Convert.Common.RangeConversion
    Mock Test-StringIsLessThanOrEqualButNot  -ModuleName Convert.Common.RangeConversion
    Mock Test-StringIsGreaterThan -ModuleName Convert.Common.RangeConversion
    Mock Test-StringIsGreaterThanOrEqual  -ModuleName Convert.Common.RangeConversion
    Mock Test-StringIsGreaterThanButNot  -ModuleName Convert.Common.RangeConversion
    Mock Test-StringIsGreaterThanOrEqualButNot -ModuleName Convert.Common.RangeConversion
    Mock ConvertTo-OrTestString -ModuleName Convert.Common.RangeConversion
    Mock ConvertTo-TestString -ModuleName Convert.Common.RangeConversion

    It 'Should exist' {
        Get-Command -Name Get-OrganizationValueTestString | Should Not BeNullOrEmpty
    }

    Context 'NegativeOr' {
        Mock Test-StringIsNegativeOr -MockWith { return $true  } -ModuleName Convert.Common.RangeConversion
        Mock Test-StringIsPositiveOr -MockWith { return $false } -ModuleName Convert.Common.RangeConversion
        Mock ConvertTo-OrTestString  { return 'ConvertedString' } -ModuleName Convert.Common.RangeConversion -ParameterFilter {$String -eq "";
            $Operator -eq 'Equal'}
        It 'Should return the correct string' {
            Get-OrganizationValueTestString -String "1 or 2 = a Finding" | Should Be "ConvertedString"
        }

    }
}

Describe 'Get-TestStringTokenNumbers' {

    It "Should exist" {
        Get-Command Get-TestStringTokenNumbers | Should Not BeNullOrEmpty
    }

    $Strings = @{
        'Greater than 30'                 = "30"
        '30 (or greater)'                 = "30"
        'Greater than 30 (but not 60)'    = "30", "60"
        '30 (or greater, but not 60)'     = "30", "60"
        'less than 30'                    = "30"
        '30 (or less)'                    = "30"
        "Less than 30 (but not 0)"        = "30", "0"
        "30 (or less, but not 0)"         = "30", "0"
        "0x0000000f (15) (or less)"       = "15"
        "0x00008000 (32768) (or greater)" = "32768"
    }

    Foreach ($string in $strings.GetEnumerator())
    {
        It "Should return '$($string.Value)' when given '$($string.Key)'" {
            Get-TestStringTokenNumbers -String $string.Key | Should Be $string.Value
        }
    }
}

Describe 'Get-TestStringTokenList' {

    It "Should exist" {
        Get-Command Get-TestStringTokenList | Should Not BeNullOrEmpty
    }

    Context 'CommandTokens ParameterSet' {
        $strings = @{
            'Greater than 30'                 = "greater than"
            '30 (or greater)'                 = "or greater"
            'Greater than 30 (but not 60)'    = "greater than but not"
            '30 (or greater, but not 60)'     = "or greater but not"
            'less than 30'                    = "less than"
            '30 (or less)'                    = "or less"
            "Less than 30 (but not 0)"        = "less than but not"
            "30 (or less, but not 0)"         = "or less but not"
            " 0x0000000f (15) (or less)"       = "or less"
            "0x00008000 (32768) (or greater)" = "or greater"
        }

        Foreach ($string in $strings.GetEnumerator())
        {
            It "Should return '$($string.Value)' when given '$($string.Key)'" {
                Get-TestStringTokenList -String $string.Key | Should Be $string.Value
            }
        }
    }

    Context 'StringTokens ParameterSet' {
        $strings = @{
            '"text1" is between quotes' = "text1"
            '"text1" and "text2" are between quotes' = @('text1','text2')
            '"text1" and "text2" but "text3" are between quotes' = @('text1','text2','text3')
        }

        Foreach ($string in $strings.GetEnumerator())
        {
            It "Should return '$($string.Value)' when given '$($string.Key)'" {
                Get-TestStringTokenList -String $string.Key -StringTokens | Should Be $string.Value
            }
        }
    }
}

Describe 'ConvertTo-TestString' {
    $Strings = @{
        'Greater than 30'                 = "{0} -gt '30'"
        '30 (or greater)'                 = "{0} -ge '30'"
        'Greater than 30 (but not 60)'    = "{0} -gt '30' -and {0} -lt '60'"
        '30 (or greater, but not 60)'     = "{0} -ge '30' -and {0} -lt '60'"
        'less than 30'                    = "{0} -lt '30'"
        '30 (or less)'                    = "{0} -le '30'"
        "Less than 30 (but not 0)"        = "{0} -lt '30' -and {0} -gt '0'"
        "30 (or less, but not 0)"         = "{0} -le '30' -and {0} -gt '0'"
        "  0x0000000f (15) (or less)"     = "{0} -le '15'"
        "0x00008000 (32768) (or greater)" = "{0} -ge '32768'"
    }
    Foreach ($string in $strings.GetEnumerator())
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
Describe "Test-StringIsNegativeOr" {

        It "Verifies the function exists" {
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

        Foreach($positiveMatchString in $positiveMatchStrings)
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

        Foreach($negativeMatchString in $negativeMatchStrings)
        {
            It "Should be false with '$negativeMatchString'" {
                Test-StringIsNegativeOr -String $negativeMatchString | Should be $false
            }
        }
}

Describe "Test-StringIsPositiveOr" {

    It "Verifies the function exists" {
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

    Foreach ($positiveMatchString in $positiveMatchStrings)
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

    Foreach ($negativeMatchString in $negativeMatchStrings)
    {
        It "Should be false with '$negativeMatchString'" {
            Test-StringIsPositiveOr -String $negativeMatchString | Should be $false
        }
    }
}

Describe 'ConvertTo-OrTestString' {

    It "Should exist" {
        Get-Command ConvertTo-OrTestString | Should Not BeNullOrEmpty
    }

    Context 'NotMatch' {
        $operator = "NotMatch"
        $positiveMatchStrings = @{
            "1 or 2 = a Finding"   = "{0} -notmatch '1|2'"
            "10 or 20 = a Finding" = "{0} -notmatch '10|20'"
        }

        Foreach ($positiveMatchString in $positiveMatchStrings.GetEnumerator())
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
            "1 or 2 "                                  = "{0} -match '1|2'"
            "10 or 20 "                                = "{0} -match '10|20'"
            "1 (Lock Workstation) or 2 (Force Logoff)" = "{0} -match '1|2'"
        }

        Foreach ($positiveMatchString in $positiveMatchStrings.GetEnumerator())
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

    Foreach ($string in $strings)
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

    Foreach ($string in $strings)
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

    Foreach ($string in $strings)
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

    Foreach ($string in $strings)
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

    Foreach ($string in $strings)
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

    Foreach ($string in $strings)
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

    Foreach ($string in $strings)
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
    )

    Foreach ($string in $strings)
    {
        It "Should return $true when given '$string'" {
            Test-StringIsLessThanOrEqualButNot -String $string | Should Be $true
        }
    }
}
#endregion
#region Multiple Values
Describe 'Test-StringIsMultipleValue' {

        $strings = @(
            'Possible values are NoSync, NTP, NT5DS, AllSync'
        )

        Foreach ($string in $strings)
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
    Foreach ($string in $strings.GetEnumerator())
    {
        It "Should return '$($string.Value)' when given '$($string.key)'" {
            ConvertTo-MultipleValue -String $string.key | Should Be $string.Value
        }
    }
}
#endregion
#region Security Policy
Describe 'Get-SecurityPolicyString' {
    $checkContent = 'Verify the effective setting in Local Group Policy Editor.
    Run "gpedit.msc".

    Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Account Lockout Policy.

    If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.'
    $match = '"Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.'
    It 'Should return the second string in quotes' {

        $checkContent = (Split-TestStrings -CheckContent  $checkContent)
        Get-SecurityPolicyString -CheckContent $checkContent | Should Be $match
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

    Context "Not Match" {

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
        'If the "Reset account lockout counter after" value is less than "15" minutes , this is a finding.'                                                         = "'{0}' -ge '15'";
        'If the value for the "Minimum password age" is set to "0" days ("Password can be changed immediately."), this is a finding.'                               = "'{0}' -ne '0'";
        'If the "Account lockout threshold" is "0" or more than "3" attempts, this is a finding.'                                                                   = "'{0}' -le '3' -and '{0}' -ne '0'";
        'If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.'                                                           = "'{0}' -ge '15' -or '{0}' -eq '0'";
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
