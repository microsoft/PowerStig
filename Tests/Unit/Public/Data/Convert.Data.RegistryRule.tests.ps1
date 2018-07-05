#region Header
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Tests
Describe "DscRegistryValueType Data Section" {

    # Validate the static data section to convert the registry value types
    $registryTypes = @{
        'REG_SZ'        = 'String'
        'REG_BINARY'    = 'Binary'
        'REG_DWORD'     = 'Dword'
        'REG_QWORD'     = 'Qword'
        'REG_MULTI_SZ'  = 'MultiString'
        'REG_EXPAND_SZ' = 'ExpandableString'
        'Does Not Exist' = 'Does Not Exist'
    }

    foreach ($registryType in $registryTypes.GetEnumerator())
    {
        It "'$($registryType.Key)' should exist and return '$($registryType.Value)'" {
            $dscRegistryValueType.($registryType.Key) | Should Be $registryType.Value
        }
    }
}

Describe "RegistryRegularExpression Data Section" {

    Context "Hive Match" {

        $hiveStrings = @(
            'Hive:HKEY_LOCAL_MACHINE',
            'Hive: HKEY_LOCAL_MACHINE',
            'Registry Hive:HKEY_LOCAL_MACHINE',
            'Registry Hive: HKEY_LOCAL_MACHINE'
        )

        foreach ($string in $hiveStrings)
        {
            It "Should match '$string'" {
                $string | Should Match $RegistryRegularExpression.registryHive
            }
        }
    }

    Context "Path Match" {

        $pathStrings = @(
            'SubKey : \Path\To\RegistryValue',
            'Registry Path :\Path\To\RegistryValue'
        )

        foreach ($string in $pathStrings)
        {
            It "Should match '$string'" {
                $string | Should Match $RegistryRegularExpression.registryPath
            }
        }
    }

    Context "Type Match" {

        $typeStrings = @(
            'Type:REG_SZ',
            'Type: REG_BINARY',
            '  Type:  REG_DWORD',
            ' Type: REG_QWORD',
            'Type: REG_MULTI_SZ ',
            'Type:  REG_EXPAND_SZ'
        )

        foreach ($string in $typeStrings)
        {
            It "Should match '$string'" {
                $string | Should Match $RegistryRegularExpression.registryEntryType
            }
        }
    }

    Context "ValueName Match" {
        $valueNameStrings = @(
            'Value Name : SettingName'
        )

        foreach ($string in $valueNameStrings)
        {
            It "Should match '$string'" {
                $string | Should Match $RegistryRegularExpression.registryValueName
            }
        }
    }

    Context "ValueData Match" {
        $valueNameStrings = @(
            'Value : 1'
        )

        foreach ($string in $valueNameStrings)
        {
            It "Should match '$string'" {
                $string | Should Match $RegistryRegularExpression.registryValueData
            }
        }

        $valueNameStringsToNotMatch = @(
            'The policy referenced configures the following registry value:'
        )

        foreach ($string in $valueNameStringsToNotMatch)
        {
            It "Should not match '$string'" {
                $string | Should Not Match $RegistryRegularExpression.registryValueData
            }
        }
    }

    Context "Value Data Range Match" {

        $rangeStrings = @(
            'Possible values are'
        )

        foreach ($string in $rangeStrings)
        {
            It "Should match '$string'" {
                $string | Should Match $RegistryRegularExpression.registryValueRange
            }
        }
    }
}
#endregion Tests
