#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup

#endregion
#region Tests
try
{
    Describe 'Test-SingleLineRegistryRule' {

        It 'Should exist' {
            Get-Command Test-SingleLineRegistryRule | Should Not BeNullOrEmpty
        }

        It "Should return $true when 'HKCU\' is found" {
            Test-SingleLineRegistryRule -CheckContent "HKCU\" | Should Be $true
        }

        It "Should return $true when 'HKLM\' is found" {
            Test-SingleLineRegistryRule -CheckContent "HKLM\" | Should Be $true
        }

        It "Should return $false when 'Permission' is found" {
            Test-SingleLineRegistryRule -CheckContent "Permission" | Should Be $false
        }
    }

    Describe 'Get-SingleLineRegistryPath ' {

        It "Should return the full Current User registry path" {
            $checkContent = 'HKCU\Path\To\Value'
            $returnContent = 'HKEY_CURRENT_USER\Path\To\Value'
            Get-SingleLineRegistryPath  -CheckContent $checkContent | Should Be $returnContent
        }

        It "Should return the full Local Machine registry path" {
            $checkContent = 'HKLM\Path\To\Value'
            $returnContent = 'HKEY_LOCAL_MACHINE\Path\To\Value'
            Get-SingleLineRegistryPath  -CheckContent $checkContent | Should Be $returnContent
        }

        It "Should return the full Current User registry path without a trailing period" {
            $checkContent = 'HKCU\Path\To\Value.'
            $returnContent = 'HKEY_CURRENT_USER\Path\To\Value'
            Get-SingleLineRegistryPath  -CheckContent $checkContent | Should Be $returnContent
        }

        It "Should return the full Local Machine registry path without a trailing period" {
            $checkContent = 'HKLM\Path\To\Value.'
            $returnContent = 'HKEY_LOCAL_MACHINE\Path\To\Value'
            Get-SingleLineRegistryPath  -CheckContent $checkContent | Should Be $returnContent
        }
    }

    #########################################   Registry Type   ########################################
    Describe "Get-RegistryValueTypeFromSingleLineStig" {
        # A list of the registry types in the STIG(key) to DSC(value) format
        # this is a seperate list to detect changes in the script
        $registryTypes = @(
            'REG_SZ', 'REG_BINARY', 'REG_DWORD', 'REG_QWORD', 'REG_MULTI_SZ', 'REG_EXPAND_SZ'
        )

        foreach ( $registryType in $registryTypes )
        {
            $checkContent = "Criteria: If the value ""1001"" is $registryType = 3"
            Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is REG_SZ = 3'} -ModuleName Convert.SingleLineRegistryRule -ParameterFilter {$CheckContent -match 'REG_SZ'}
            Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is REG_BINARY = 3'} -ModuleName Convert.SingleLineRegistryRule -ParameterFilter {$CheckContent -match 'REG_BINARY'}
            Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is REG_QWORD = 3'} -ModuleName Convert.SingleLineRegistryRule -ParameterFilter {$CheckContent -match 'REG_QWORD'}
            Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is REG_MULTI_SZ = 3'} -ModuleName Convert.SingleLineRegistryRule -ParameterFilter {$CheckContent -match 'REG_MULTI_SZ'}
            Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is DWORD = 3'} -ModuleName Convert.SingleLineRegistryRule -ParameterFilter {$CheckContent -match 'REG_DWORD'}
            Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is REG_EXPAND_SZ = 3'} -ModuleName Convert.SingleLineRegistryRule -ParameterFilter {$CheckContent -match 'REG_EXPAND_SZ'}

            It "Should return '$registryType' from '$checkContent'" {

                $RegistryValueType = Get-RegistryValueTypeFromSingleLineStig -CheckContent $checkContent
                $RegistryValueType | Should Be $registryType
            }
        }

        It "Should return 'null' with invalid registry type" {

            Get-RegistryValueTypeFromSingleLineStig -CheckContent 'Mocked data' | Should Be $null
        }
    }

    #########################################   Registry Type   ########################################
    #########################################   Registry Name   ########################################
    Describe "Get-RegistryValueNameFromSingleLineStig" {

        $valueName = 'ValueName'
        $checkContent = "Criteria: If the value ""$valueName"" is REG_Type = 2, this is not a finding."
        It "Should return '$valueName' from '$checkContent'" {
            Get-RegistryValueNameFromSingleLineStig -CheckContent $checkContent | Should Be $valueName
        }
    }
    #########################################   Registry Name   ########################################
    #########################################   Registry Data   ########################################
    Describe "Get-RegistryValueDataFromSingleStig" {

        $valueData = '2'
        $checkContent = "Criteria: If the value ""ValueName"" is REG_Type = $valueData, this is not a finding."

        It "Should return '$valueData' from '$checkContent'" {
            Get-RegistryValueDataFromSingleStig -CheckContent $checkContent | Should Be $valueData
        }
    }
    #########################################   Registry Data   ########################################
    ######################################   Ancillary functions   #####################################
    Describe 'Get-RegistryValueStringFromSingleLineStig' {

        $registryValueName = 'XL4Workbooks'
        $registryValueType = 'REG_DWORD'
        $registryValueData = '2'
        $registryValueInnerString = """$registryValueName"" is $registryValueType = $registryValueData"
        $registryValueString = "Criteria: If the value $registryValueInnerString, this is not a finding."
        $checkContent = "
    HKCU\Path\to\value

    $registryValueString" -Split "\n"

        It "Should return the correct full string" {
            $fullString = Get-RegistryValueStringFromSingleLineStig -CheckContent $checkContent
            $fullString | Should Be $registryValueString
        }

        <#
        "Criteria: If the value HtmlandXmlssFiles is REG_DWORD = 2, this is not a finding.",
        "Criteria: If the value DifandSylkFiles is REG_DWORD = 2, this is not a finding.",
        "Criteria: If the value XL9597WorkbooksandTemplates is REG_DWORD = 5, this is not a finding.",
        "Criteria: If the value of excel.exe is REG_DWORD = 1, this is not a finding.",
        "Criteria: If the value openinprotectedview does not exist, this is not a finding. If the value is REG_DWORD = 1, this is not a finding.",
        "Criteria: If the value ExcelBypassEncryptedMacroScan does not exist, this is not a finding. If the value is REG_DWORD = 0, this is not a finding.",
        "Criteria: If the value DefaultFormat is REG_DWORD =  0x00000033(hex) or 51 (Decimal), this is not a finding."
    #>
        $stringFormats = @(
            "Criteria: If the value of $registryValueInnerString, this is not a finding.",
            "Criteria: If the value $registryValueInnerString, this is not a finding."
        )
        foreach ($stringFormat in $stringFormats)
        {
            It "Should return the correct trimmed string" {
                $trimmedString = Get-RegistryValueStringFromSingleLineStig -CheckContent $stringFormat -Trim
                $trimmedString | Should Be $registryValueInnerString
            }
        }


        It "Should remove extra spaces from the string" {
            $checkContent = "Criteria: If   the value  XL4Workbooks  is REG_DWORD = 2, this is not a finding."

            $trimmedString = Get-RegistryValueStringFromSingleLineStig -CheckContent $checkContent
            $trimmedString | Should Be "Criteria: If the value XL4Workbooks is REG_DWORD = 2, this is not a finding."
        }

    }

    Describe "Test-SingleLineStigFormat" {
        $checkContent = "",
        "HKLM\to\value",
        "",
        "Criteria: If the value XL4Workbooks is REG_DWORD = 2, this is not a finding."

        It "Should return $true when match Office format" {
            Test-SingleLineStigFormat -CheckContent $checkContent | Should Be $true
        }

        $checkContent = "Registry Hive: HKEY_LOCAL_MACHINE" +
        "Registry Path:  \Path\To\Value"
        It "Should return $false when not match Office foramt" {
            Test-SingleLineStigFormat -CheckContent $checkContent | Should Be $false
        }
    }
}
catch
{
    Remove-Variable STIGSettings -Scope Global
}
#endregion Tests
