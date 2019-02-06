#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $filePath = "$PSScriptRoot\..\..\StigData\Archive"

    # Building the baseline rule set values
    $stigs = [ordered]@{
        'U_Mozilla_Firefox_STIG_V4R23_Manual-xccdf.xml'              = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 1
            FileContentRule              = 20
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 6
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_Mozilla_Firefox_STIG_V4R24_Manual-xccdf.xml'              = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = $null
            FileContentRule              = 21
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 6
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_SQL_Server_2012_Database_STIG_V1R17_Manual-xccdf.xml'     = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 13
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 14
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = 1
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_SQL_Server_2012_Database_STIG_V1R18_Manual-xccdf.xml'  = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 13
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 14
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = 1
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_SQL_Server_2012_Instance_STIG_V1R16_Manual-xccdf.xml'     = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 45
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 75
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = 33
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_SQL_Server_2016_Instance_STIG_V1R3_Manual-xccdf.xml'   = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 90
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 18
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = 5
            ServiceRule                  = $null
            SqlScriptQueryRule           = 6
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_Windows_10_STIG_V1R16_Manual-xccdf.xml'                   = @{
            AccountPolicyRule            = 9
            AuditPolicyRule              = 35
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 4
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 26
            MimeTypeRule                 = $null
            PermissionRule               = 9
            ProcessMitigationRule        = 31
            RegistryRule                 = 133
            SecurityOptionRule           = 5
            ServiceRule                  = 1
            SqlScriptQueryRule           = $null
            UserRightRule                = 30
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = 9
            WmiRule                      = 2
        }
        'U_Windows_2012_and_2012_R2_DC_STIG_V2R15_Manual-xccdf.xml'  = @{
            AccountPolicyRule            = 14
            AuditPolicyRule              = 36
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 17
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 48
            MimeTypeRule                 = $null
            PermissionRule               = 18
            ProcessMitigationRule        = $null
            RegistryRule                 = 205
            SecurityOptionRule           = 5
            ServiceRule                  = 16
            SqlScriptQueryRule           = $null
            UserRightRule                = 31
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = 2
            WmiRule                      = 2
        }
        'U_MS_Windows_2012_Server_DNS_STIG_V1R10_Manual-xccdf.xml'   = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = 1
            DnsServerSettingRule         = 2
            DocumentRule                 = 19
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 64
            MimeTypeRule                 = $null
            PermissionRule               = 2
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = 4
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = 1
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_Windows_2012_Server_DNS_STIG_V1R11_Manual-xccdf.xml'   = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = 1
            DnsServerSettingRule         = 2
            DocumentRule                 = 19
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 64
            MimeTypeRule                 = $null
            PermissionRule               = 2
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = 4
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = 1
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_IIS_8-5_Server_STIG_V1R5_Manual-xccdf.xml'             = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 14
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = 4
            ManualRule                   = 15
            MimeTypeRule                 = 5
            PermissionRule               = 1
            ProcessMitigationRule        = $null
            RegistryRule                 = 5
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = 8
            WinEventLogRule              = $null
            WindowsFeatureRule           = 1
            WmiRule                      = $null
        }
        'U_MS_IIS_8-5_Server_STIG_V1R6_Manual-xccdf.xml'             = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 14
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = 4
            ManualRule                   = 16
            MimeTypeRule                 = 5
            PermissionRule               = 1
            ProcessMitigationRule        = $null
            RegistryRule                 = 5
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = 8
            WinEventLogRule              = $null
            WindowsFeatureRule           = 1
            WmiRule                      = $null
        }
        'U_IIS_8-5_Site_STIG_V1R2_Manual-xccdf.xml'                  = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 19
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = 4
            ManualRule                   = 14
            MimeTypeRule                 = 5
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = 5
            WebConfigurationPropertyRule = 17
            WinEventLogRule              = $null
            WindowsFeatureRule           = 1
            WmiRule                      = $null
        }
        'U_MS_IIS_8-5_Site_STIG_V1R5_Manual-xccdf.xml'               = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 16
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = 4
            ManualRule                   = 12
            MimeTypeRule                 = 5
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = 5
            WebConfigurationPropertyRule = 16
            WinEventLogRule              = $null
            WindowsFeatureRule           = 1
            WmiRule                      = $null
        }
        'U_Windows_2012_and_2012_R2_MS_STIG_V2R13_Manual-xccdf.xml'  = @{
            AccountPolicyRule            = 9
            AuditPolicyRule              = 31
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 13
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 38
            MimeTypeRule                 = $null
            PermissionRule               = 11
            ProcessMitigationRule        = $null
            RegistryRule                 = 203
            SecurityOptionRule           = 5
            ServiceRule                  = 7
            SqlScriptQueryRule           = $null
            UserRightRule                = 34
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = 2
            WmiRule                      = 2
        }
        'U_Active_Directory_Domain_STIG_V2R11_Manual-xccdf.xml'      = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 13
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 23
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_Active_Directory_Forest_V2R8_STIG_Manual-xccdf.xml'       = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 1
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 4
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_DotNet_Framework_4-0_STIG_V1R6_Manual-xccdf.xml'       = @{
            AccountPolicyRule = $null
            AuditPolicyRule = $null
            DnsServerRootHintRule = $null
            DnsServerSettingRule = $null
            DocumentRule = 4
            FileContentRule = $null
            GroupRule = $null
            IisLoggingRule = $null
            ManualRule = 12
            MimeTypeRule = $null
            PermissionRule = $null
            ProcessMitigationRule = $null
            RegistryRule = $null
            SecurityOptionRule = $null
            ServiceRule = $null
            SqlScriptQueryRule = $null
            UserRightRule = $null
            WebAppPoolRule = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule = $null
            WindowsFeatureRule = $null
            WmiRule = $null
        }
        'U_MS_DotNet_Framework_4-0_STIG_V1R4_Manual-xccdf.xml'       = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = 4
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 11
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = $null
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_Windows_Firewall_STIG_V1R6_Manual-xccdf.xml'              = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = $null
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = 1
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = 38
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_Excel_2013_STIG_V1R7_Manual-xccdf.xml'                 = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = $null
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = $null
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = 48
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_IE11_STIG_V1R15_Manual-xccdf.xml'                      = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = $null
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = $null
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = 140
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_IE11_STIG_V1R16_Manual-xccdf.xml'                      = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = $null
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = $null
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = 140
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MicrosoftOutlook2013_STIG_V1R12_Manual-xccdf.xml'         = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = $null
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = $null
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = 82
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MicrosoftOutlook2013_STIG_V1R13_Manual-xccdf.xml'         = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = $null
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = $null
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = 82
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_PowerPoint_2013_V1R6_Manual-xccdf.xml'                 = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = $null
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = $null
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = 41
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_Word_2013_STIG_V1R6_Manual-xccdf.xml'                  = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = $null
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = $null
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = 36
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
        'U_MS_Windows_Defender_Antivirus_STIG_V1R4_Manual-xccdf.xml' = @{
            AccountPolicyRule            = $null
            AuditPolicyRule              = $null
            DnsServerRootHintRule        = $null
            DnsServerSettingRule         = $null
            DocumentRule                 = $null
            FileContentRule              = $null
            GroupRule                    = $null
            IisLoggingRule               = $null
            ManualRule                   = $null
            MimeTypeRule                 = $null
            PermissionRule               = $null
            ProcessMitigationRule        = $null
            RegistryRule                 = 41
            SecurityOptionRule           = $null
            ServiceRule                  = $null
            SqlScriptQueryRule           = $null
            UserRightRule                = $null
            WebAppPoolRule               = $null
            WebConfigurationPropertyRule = $null
            WinEventLogRule              = $null
            WindowsFeatureRule           = $null
            WmiRule                      = $null
        }
    }
    #endregion
    #region Tests
    # Verify conversion report rule set values are equal to baseline values
    Describe 'STIG Conversion' {

        foreach ($file in $stigs.keys)
        {
            $path = (Get-ChildItem -Path $filePath -Filter $file -Recurse).FullName
            $conversionReport = Get-ConversionReport -Path $path
            $ruleConversion = $stigs.item($file)

            Context "$file" {

                foreach ($rule in $ruleConversion.keys)
                {
                    $ruleCount = $ruleConversion.$rule

                    if ($null -eq $ruleCount)
                    {
                        $ruleCountTitle = '0'
                    }
                    else
                    {
                        $ruleCountTitle = $ruleCount
                    }
                    It "Should return $ruleCountTitle $rule" {
                        ($conversionReport | Where-Object {$_.type -eq $rule}).conversionpass | Should be $ruleCount
                    }
                }
            }
        }
    }

    Describe 'PowerStig output' {

        $path = (Get-ChildItem -Path $filePath -File -Exclude '*.md' -Recurse)[0].FullName

        It 'Should not throw an error when a STIG is converted' {
            {ConvertTo-PowerStigXml -Path $path -Destination $TestDrive} |
                Should Not Throw
        }

        It 'Should contain Stig Rules' {
            $output = Get-ChildItem -Path $TestDrive -Filter *.xml
            [xml] $stigContent = Get-Content -Path $output.FullName -Raw

            $stigContent.DISASTIG | Should -Not -Be $null
        }

        It 'Should append a blank line to the end of the file' {
            $output = Get-ChildItem -Path $TestDrive -Filter *.xml
            (Get-Content -Path $output.FullName -Raw)[-1] -eq "`n" | Should Be $true
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
