using module ..\..\..\..\Public\Class\Convert.RegistryRule.psm1
#region Convert Public Class Header V1
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$rule = [RegistryRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$registriesToTest = @(
    @{
        Hive                        = 'HKEY_LOCAL_MACHINE'
        Path                        = '\Software\Policies\Microsoft\WindowsMediaPlayer'
        OrganizationValueRequired   = 'False'
        OrganizationValueTestString = ''
        ValueData                   = '1'
        ValueName                   = 'GroupPrivacyAcceptance'
        ValueType                   = 'DWORD'
        CheckContent                = 'Windows Media Player is not installed by default.  If it is not installed, this is NA.
        
                  If the following registry value does not exist or is not configured as specified, this is a finding:
        
                  Registry Hive: HKEY_LOCAL_MACHINE
                  Registry Path: \Software\Policies\Microsoft\WindowsMediaPlayer\
        
                  Value Name: GroupPrivacyAcceptance
        
                  Type: REG_DWORD
                  Value: 1'
    },
    @{
        Hive                        = 'HKEY_LOCAL_MACHINE'
        Path                        = '\System\CurrentControlSet\Services\W32Time\Config'
        OrganizationValueRequired   = 'True'
        OrganizationValueTestString = "{0} -match '2|3'"
        ValueData                   = ''
        ValueName                   = 'EventLogFlags'
        ValueType                   = 'DWORD'
        CheckContent                = 'Verify logging is configured to capture time source switches.
        
                  If the Windows Time Service is used, verify the following registry value.  If it is not configured as specified, this is a finding.
        
                  Registry Hive: HKEY_LOCAL_MACHINE
                  Registry Path: \System\CurrentControlSet\Services\W32Time\Config\
        
                  Value Name: EventLogFlags
        
                  Type: REG_DWORD
                  Value: 2 or 3
        
                  If another time synchronization tool is used, review the available configuration options and logs.  If the tool has time source logging capability and it is not enabled, this is a finding.'
    },
    @{
        Hive                        = 'HKEY_LOCAL_MACHINE'
        Path                        = '\System\CurrentControlSet\Control\Session Manager\Subsystems'
        OrganizationValueRequired   = 'False'
        OrganizationValueTestString = ''
        ValueData                   = ''
        ValueName                   = 'Optional'
        ValueType                   = 'MultiString'
        CheckContent                = 'If the following registry value does not exist or is not configured as specified, this is a finding:
        
                  Registry Hive: HKEY_LOCAL_MACHINE
                  Registry Path: \System\CurrentControlSet\Control\Session Manager\Subsystems\
        
                  Value Name: Optional
        
                  Value Type: REG_MULTI_SZ
                  Value: (Blank)'
    },
    @{
        Hive                        = 'HKEY_LOCAL_MACHINE'
        Path                        = '\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
        OrganizationValueRequired   = 'True'
        OrganizationValueTestString = "{0} -le '5'"
        ValueData                   = ''
        ValueName                   = 'ScreenSaverGracePeriod'
        ValueType                   = 'String'
        CheckContent                = 'If the following registry value does not exist or is not configured as specified, this is a finding:
        
                  Registry Hive: HKEY_LOCAL_MACHINE
                  Registry Path: \Software\Microsoft\Windows NT\CurrentVersion\Winlogon\
        
                  Value Name: ScreenSaverGracePeriod
        
                  Value Type: REG_SZ
                  Value: 5 (or less)'
    },
    @{
        Hive                        = 'HKEY_LOCAL_MACHINE'
        Path                        = '\System\CurrentControlSet\Control\Lsa\MSV1_0'
        OrganizationValueRequired   = 'False'
        OrganizationValueTestString = ''
        ValueData                   = '537395200'
        ValueName                   = 'NTLMMinServerSec'
        ValueType                   = 'DWORD'
        CheckContent                = 'If the following registry value does not exist or is not configured as specified, this is a finding:
        
                  Registry Hive: HKEY_LOCAL_MACHINE
                  Registry Path: \System\CurrentControlSet\Control\Lsa\MSV1_0\
        
                  Value Name: NTLMMinServerSec
        
                  Value Type: REG_DWORD
                  Value: 0x20080000 (537395200)'
    },
    @{
        Hive                        = 'HKEY_LOCAL_MACHINE'
        Path                        = '\SYSTEM\CurrentControlSet\Control\Lsa'
        OrganizationValueRequired   = 'False'
        ValueName                   = 'RestrictRemoteSAM'
        ValueData                   = 'O:BAG:BAD:(A;;RC;;;BA)'
        ValueType                   = 'String'
        CheckContent                = 'This is NA prior to v1607 of Windows 10.

                                    If the following registry value does not exist or is not configured as specified, this is a finding:

                                    Registry Hive: HKEY_LOCAL_MACHINE
                                    Registry Path: \SYSTEM\CurrentControlSet\Control\Lsa\

                                    Value Name: RestrictRemoteSAM

                                    Value Type: REG_SZ
                                    Value: O:BAG:BAD:(A;;RC;;;BA)'
    },
    @{
        Hive                        = 'HKEY_LOCAL_MACHINE'
        Path                        = '\SOFTWARE\Classes\batfile\shell\runasuser', '\SOFTWARE\Classes\cmdfile\shell\runasuser', '\SOFTWARE\Classes\exefile\shell\runasuser', '\SOFTWARE\Classes\mscfile\shell\runasuser'
        OrganizationValueRequired   = 'False'
        ValueName                   = 'SuppressionPolicy'
        ValueData                   = '4096'
        ValueType                   = 'Dword'
        CheckContent                = 'If the following registry values do not exist or are not configured as specified, this
                                    is a finding.
                                    The policy configures the same Value Name, Type and Value under four different registry
                                    paths.

                                    Registry Hive:  HKEY_LOCAL_MACHINE
                                    Registry Paths:
                                    \SOFTWARE\Classes\batfile\shell\runasuser\
                                    \SOFTWARE\Classes\cmdfile\shell\runasuser\
                                    \SOFTWARE\Classes\exefile\shell\runasuser\
                                    \SOFTWARE\Classes\mscfile\shell\runasuser\

                                    Value Name:  SuppressionPolicy

                                    Type:  REG_DWORD
                                    Value:  0x00001000 (4096)'
    }
)
#endregion
#region Class Tests
Describe "$($rule.GetType().Name) Child Class" {
    
    Context 'Base Class' {        
        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties' {
         
        $classProperties = @('Key', 'ValueName', 'ValueData', 'ValueType', 'Ensure')

        foreach ( $property in $classProperties )
        {
            It "Should have a property named '$property'" {
                ( $rule | Get-Member -Name $property ).Name | Should Be $property
            }
        }
    }

    Context 'Class Methods' {
        
        $classMethods = @('FormatMultiStringRegistryData',
            'GetIntegerFromHex', 'GetNumberFromString', 'GetMultiValueRegistryStringData', 
            'GetValidEnabledOrDisabled', 'IsDataBlank', 'IsDataEnabledOrDisabled', 'IsDataHexCode', 
            'IsDataInteger', 'SetEnsureFlag', 'SetKey', 'GetValueData', 'SetValueName', 
            'SetValueType', 'TestValueDataStringForRange')

        foreach ( $method in $classMethods )
        {
            It "Should have a method named '$method'" {
                ( $rule | Get-Member -Name $method ).Name | Should Be $method
            }
        }

        # If new methods are added this will catch them so test coverage can be added
        It "Should not have more methods than are tested" {
            $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
            $memberActual = ( $rule | Get-Member -MemberType Method ).Name
            $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
            $compare.Count | Should Be 0
        }
    }  
}
#endregion
#region Method function Tests
Describe 'Get-RegistryKey' {
    
    foreach ( $registry in $registriesToTest )
    {
        $expectedPaths = $registry.Path | Sort-Object -Descending
        $registryKey = Get-RegistryKey -CheckContent ($registry.CheckContent -split '\n').Trim()

        foreach ($expectedPath in $expectedPaths)
        {
            It "Should return '$($registry.Hive + $expectedPath)'" {
                $result = $registryKey | Where-Object -FilterScript { $PSItem -like "*$expectedPath" }
                $result | Should Be ($registry.Hive + $expectedPath)
            }
        }
        
    }
}

Describe 'Get-RegistryValueType' {
    
    foreach ( $registry in $registriesToTest )
    {
        It "Should return '$($registry.ValueType)'" {
            $registryKey = Get-RegistryValueType -CheckContent ($registry.CheckContent -split '\n')
            $registryKey | Should Be ($registry.ValueType)
        } 
    }
}

Describe 'Get-RegistryValueName' {
    
    foreach ( $registry in $registriesToTest )
    {
        It "Should return '$($registry.ValueName)'" {
            $registryKey = Get-RegistryValueName -CheckContent ($registry.CheckContent -split '\n')
            $registryKey | Should Be ($registry.ValueName)
        } 
    }
}

Describe 'Get-RegistryValueData' {
    
    foreach ( $registry in $registriesToTest )
    {
        if ($registry.OrganizationValueRequired -eq 'False')
        {
            It "Should return '$($registry.ValueData)'" {
                $registryKey = Get-RegistryValueData -CheckContent ($registry.CheckContent -split '\n')
                $result = $registryKey -match "$($registry.ValueData)|Blank" -or $registryKey -eq $registry.ValueData
                $result | Should Be $true
            }
        }
    }
}

Describe 'Get-RegistryHiveFromWindowsStig' {
    
    foreach ( $registry in $registriesToTest )
    {
        It "Should return '$($registry.Hive)'" {
            $registryKey = Get-RegistryHiveFromWindowsStig -CheckContent ($registry.CheckContent -split '\n')
            $registryKey | Should Be ($registry.Hive)
        } 
    }
}

Describe 'Get-RegistryPathFromWindowsStig' {
    
    foreach ( $registry in $registriesToTest )
    {
        It "Should return '$($registry.Path)'" {
            $registryKey = Get-RegistryPathFromWindowsStig -CheckContent ($registry.CheckContent -split '\n').Trim()
            foreach ( $key in $registryKey )
            {
                $key -in $registry.Path | Should Be $true
            }
        } 
    }
}

Describe 'Test-RegistryValueDataContainsRange' {
    
    foreach ( $registry in $registriesToTest )
    {
        It "Should return '$($registry.OrganizationValueRequired)'" {
            $registryData = Get-RegistryValueData -CheckContent ($registry.CheckContent -split '\n')
            $registryKey = Test-RegistryValueDataContainsRange -ValueDataString ($registryData)
            $registryKey | Should Be ($registry.OrganizationValueRequired)
        } 
    }
}

Describe 'Test-RegistryValueDataIsBlank' {
    
    foreach ( $registry in $registriesToTest )
    {
        $registryData = Get-RegistryValueData -CheckContent ($registry.CheckContent -split '\n')
        if ($registryData -eq '(Blank)')
        {
            $result = $true
        }
        else
        {
            $result = $false
        }

        It "Should return '$($result)'" {
            $registryKey = Test-RegistryValueDataIsBlank -ValueDataString ($registryData)
            $registryKey | Should Be ($result)
        } 
    }
}

Describe 'Test-IsValidDword' {
    
    foreach ( $registry in $registriesToTest )
    {
        $registryData = Get-RegistryValueData -CheckContent ($registry.CheckContent -split '\n')
        try {
            [void] [System.Convert]::ToInt32( $registryData )
            $result = $true
        }
        catch {
            $result = $false
        }

        It "Should return '$($result)'" {
            $registryKey = Test-IsValidDword -ValueData ($registryData)
            $registryKey | Should Be ($result)
        } 
    }
}

Describe 'Test-RegistryValueDataIsInteger' {
    
    foreach ( $registry in $registriesToTest )
    {
        $registryData = Get-RegistryValueData -CheckContent ($registry.CheckContent -split '\n')
        if ( $registryData -Match '\b([0-9]{1,})\b' )
        {
            $result = $true
        }
        else 
        {
            $result = $false   
        }

        It "Should return '$($result)'" {
            $registryKey = Test-RegistryValueDataIsInteger -ValueDataString ($registryData)
            $registryKey | Should Be ($result)
        } 
    }
}

Describe 'Get-NumberFromString' {
    
    foreach ( $registry in $registriesToTest )
    {
        $registryData = Get-RegistryValueData -CheckContent ($registry.CheckContent -split '\n')
        if( Test-RegistryValueDataIsInteger -ValueDataString ($registryData) )
        {
            if ($registry.OrganizationValueRequired -eq 'False')
            {
                It "Should return '$($registry.ValueData)'" {
                    $registryKey = Get-NumberFromString -ValueDataString ($registryData)
                    $registryKey | Should Be ($registry.ValueData)
                }
            }
        }
        else
        {
            It "Should throw if a number is not found" {
                {Get-NumberFromString -ValueDataString ($registryData)} | Should throw "Did not find an integer in $registryData."
            }
        }
    }
}

Describe 'Test-RegistryValueDataIsHexCode' {
    
    foreach ( $registry in $registriesToTest )
    {
        $registryData = Get-RegistryValueData -CheckContent ($registry.CheckContent -split '\n')
        if ( $registryData -Match '\b(0x[A-Fa-f0-9]{8}){1}\b' )
        {
            $result = $true
        }
        else 
        {
            $result = $false   
        }

        It "Should return '$($result)'" {
            $registryKey = Test-RegistryValueDataIsHexCode -ValueDataString ($registryData)
            $registryKey | Should Be ($result)
        } 
    }
}

Describe 'Get-IntegerFromHex' {
    
    foreach ( $registry in $registriesToTest )
    {
        $registryData = Get-RegistryValueData -CheckContent ($registry.CheckContent -split '\n')
        if ( Test-RegistryValueDataIsHexCode -ValueDataString ($registryData) )
        {
            $result = $true
        }
        else 
        {
            $result = $false   
        }
        
        if ($result)
        {
            It "Should return '$($registry.ValueData)'" {
                $registryKey = Get-IntegerFromHex -ValueDataString ($registryData)
                $registryKey | Should Be ($registry.ValueData)
            }
        }
        else
        {
            It "Should return an error" {
                {Get-IntegerFromHex -ValueDataString ($registryData)} | Should throw 
            }
        }
    }
}#endregion

#TODO
<#
    Test-RegistryValueDataIsEnabledOrDisabled
    Get-ValidEnabledOrDisabled
    Format-MultiStringRegistryData
    Get-MultiValueRegistryStringData
    Test-MultipleRegistryEntries
    Split-MultipleRegistryEntries
#>

#endregion
