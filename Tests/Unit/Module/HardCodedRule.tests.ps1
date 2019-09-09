#region Header
using module .\..\..\..\Module\Rule\Convert\ConvertFactory.psm1
using module .\..\..\..\Module\Rule.HardCoded\Convert\HardCodedRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleListSingle = @(
            @{
                RuleType     = 'AccountPolicyRule'
                CheckContent = "HardCodedRule(AccountPolicyRule)@{DscResource = 'AccountPolicy'; PolicyName = 'Store passwords using reversible encryption'; PolicyValue = 'Disabled'}"
                DscResource  = 'AccountPolicy'
                PolicyName   = 'Store passwords using reversible encryption'
                PolicyValue  = 'Disabled'
            },
            @{
                RuleType     = 'AuditPolicyRule'
                CheckContent = "HardCodedRule(AuditPolicyRule)@{DscResource = 'AuditPolicySubcategory'; AuditFlag = 'Success'; Ensure = 'Present'; Subcategory = 'Security Group Management'}"
                DscResource  = 'AuditPolicySubcategory'
                AuditFlag    = 'Success'
                Ensure       = 'Present'
                Subcategory  = 'Security Group Management'
            },
            @{
                RuleType     = 'AuditSettingRule'
                CheckContent = "HardCodedRule(AuditSettingRule)@{DscResource = 'AuditSetting'; DesiredValue = '6.2.9200'; Operator = '-le'; Property = 'Version'; Query = 'SELECT * FROM Win32_OperatingSystem'}"
                DscResource  = 'AuditSetting'
                DesiredValue = '6.2.9200'
                Operator     = '-le'
                Property     = 'Version'
                Query        = 'SELECT * FROM Win32_OperatingSystem'
            },
            @{
                RuleType     = 'DnsServerRootHintRule'
                CheckContent = "HardCodedRule(DnsServerRootHintRule)@{DscResource = 'Script'; HostName = '`$null'; IpAddress = '`$null'}"
                DscResource  = 'Script'
                HostName     = '$null'
                IpAddress    = '$null'
            },
            @{
                RuleType      = 'DnsServerSettingRule'
                CheckContent  = "HardCodedRule(DnsServerSettingRule)@{DscResource = 'xDnsServerSetting'; PropertyName = 'EventLogLevel'; PropertyValue = 4}"
                DscResource   = 'xDnsServerSetting'
                PropertyName  = 'EventLogLevel'
                PropertyValue = 4
            },
            @{
                RuleType     = 'FileContentRule'
                CheckContent = "HardCodedRule(FileContentRule)@{DscResource = 'ReplaceText'; Key = 'network.protocol-handler.external.shell'; Value = 'false'}"
                DscResource  = 'ReplaceText'
                Key          = 'network.protocol-handler.external.shell'
                Value        = 'false'
            },
            @{
                RuleType         = 'GroupRule'
                CheckContent     = "HardCodedRule(GroupRule)@{DscResource = 'Group'; GroupName = 'TestGroup'; MembersToExclude = 'TestMember'}"
                DscResource      = 'Group'
                GroupName        = 'TestGroup'
                MembersToExclude = 'TestMember'
            },
            @{
                RuleType     = 'IISLoggingRule'
                CheckContent = "HardCodedRule(IISLoggingRule)@{DscResource = 'XWebsite'; LogFlags = 'UserAgent,UserName,Referer'; LogFormat = 'W3C'; LogTargetW3C = 'File,ETW'}"
                DscResource  = 'XWebsite'
                LogFlags     = 'UserAgent,UserName,Referer'
                LogFormat    = 'W3C'
                LogTargetW3C = 'File,ETW'
            },
            @{
                RuleType     = 'MimeTypeRule'
                CheckContent = "HardCodedRule(MimeTypeRule)@{DscResource = 'xIisMimeTypeMapping'; Ensure = 'Present'; Extension = '.dll'; MimeType = 'application/x-msdownload'}"
                DscResource  = 'xIisMimeTypeMapping'
                Ensure       = 'Present'
                Extension    = '.dll'
                MimeType     = 'application/x-msdownload'
            },
            @{
                RuleType     = 'PermissionRule'
                CheckContent = "HardCodedRule(PermissionRule)@{DscResource = 'NTFSAccessEntry'; Force = 'True'; Path = 'C:\Test'}"
                DscResource  = 'NTFSAccessEntry'
                Force        = 'True'
                Path         = 'C:\Test'
            },
            @{
                RuleType         = 'ProcessMitigationRule'
                CheckContent     = "HardCodedRule(ProcessMitigationRule)@{DscResource = 'ProcessMitigation'; Disable = ''; Enable = 'SEHOP'; MitigationTarget = 'System'}"
                DscResource      = 'ProcessMitigation'
                Disable          = ''
                Enable           = 'SEHOP'
                MitigationTarget = 'System'
            },
            @{
                RuleType     = 'RegistryRule'
                CheckContent = "HardCodedRule(RegistryRule)@{DscResource = 'RegistryPolicyFile'; Ensure = 'Present'; Key = 'HKEY_LOCAL_MACHINE\System'; ValueData = 0; ValueName = 'Test'; ValueType = 'Dword'}"
                DscResource  = 'RegistryPolicyFile'
                Ensure       = 'Present'
                Key          = 'HKEY_LOCAL_MACHINE\System'
                ValueData    = 0
                ValueName    = 'Test'
                ValueType    = 'Dword'
            },
            @{
                RuleType     = 'RegistryRule'
                CheckContent = "HardCodedRule(RegistryRule)@{DscResource = 'Registry'; Ensure = 'Present'; Key = 'HKEY_LOCAL_MACHINE\System'; ValueData = 0; ValueName = 'Test'; ValueType = 'Dword'}"
                DscResource  = 'Registry'
                Ensure       = 'Present'
                Key          = 'HKEY_LOCAL_MACHINE\System'
                ValueData    = 0
                ValueName    = 'Test'
                ValueType    = 'Dword'
            },
            @{
                RuleType     = 'SecurityOptionRule'
                CheckContent = "HardCodedRule(SecurityOptionRule)@{DscResource = 'SecurityOption'; OptionName = 'Network access: Allow anonymous SID/Name translation'; OptionValue = 'Disabled'}"
                DscResource  = 'SecurityOption'
                OptionName   = 'Network access: Allow anonymous SID/Name translation'
                OptionValue  = 'Disabled'
            },
            @{
                RuleType     = 'ServiceRule'
                CheckContent = "HardCodedRule(ServiceRule)@{DscResource = 'Service'; Ensure = 'Present'; ServiceName = 'TestService'; ServiceState = 'Stopped'; StartupType = 'Disabled'}"
                DscResource  = 'Service'
                Ensure       = 'Present'
                ServiceName  = 'TestService'
                ServiceState = 'Stopped'
                StartupType  = 'Disabled'
            },
            @{
                RuleType     = 'SslSettingsRule'
                CheckContent = "HardCodedRule(SslSettingsRule)@{DscResource = 'xSslSettings'; Value = 'Ssl,SslNegotiateCert,SslRequireCert,Ssl128'}"
                DscResource  = 'xSslSettings'
                Value        = 'Ssl,SslNegotiateCert,SslRequireCert,Ssl128'
            },
            @{
                RuleType     = 'UserRightRule'
                CheckContent = "HardCodedRule(UserRightRule)@{DscResource = 'UserRightsAssignment'; Constant = 'SeRemoteInteractiveLogonRight'; DisplayName = 'Allow log on through Remote Desktop Services'; Force = 'True'; Identity = 'Administrators'}"
                DscResource  = 'UserRightsAssignment'
                Constant     = 'SeRemoteInteractiveLogonRight'
                DisplayName  = 'Allow log on through Remote Desktop Services'
                Force        = 'True'
                Identity     = 'Administrators'
            },
            @{
                RuleType     = 'WebAppPoolRule'
                CheckContent = "HardCodedRule(WebAppPoolRule)@{DscResource = 'xWebAppPool'; Key = 'logEventOnRecycle'; Value = '`"Time,Schedule`"'}"
                DscResource  = 'xWebAppPool'
                Key          = 'logEventOnRecycle'
                Value        = '"Time,Schedule"'
            },
            @{
                RuleType      = 'WebConfigurationPropertyRule'
                CheckContent  = "HardCodedRule(WebConfigurationPropertyRule)@{DscResource = 'xWebConfigKeyValue'; ConfigSection = '/system.webServer/security/isapiCgiRestriction'; Key = 'notListedCgisAllowed'; Value = 'false'}"
                DscResource   = 'xWebConfigKeyValue'
                ConfigSection = '/system.webServer/security/isapiCgiRestriction'
                Key           = 'notListedCgisAllowed'
                Value         = 'false'
            },
            @{
                RuleType     = 'WindowsFeatureRule'
                CheckContent = "HardCodedRule(WindowsFeatureRule)@{DscResource = 'WindowsFeature'; Ensure = 'Present'; Name = 'TestFeature'}"
                DscResource  = 'WindowsFeature'
                Ensure       = 'Present'
                Name         = 'TestFeature'
            },
            @{
                RuleType     = 'WinEventLogRule'
                CheckContent = "HardCodedRule(WinEventLogRule)@{DscResource = 'xWinEventLog'; IsEnabled = 'True'; LogName = 'Microsoft-Windows-DnsServer/Analytical'}"
                DscResource  = 'xWinEventLog'
                IsEnabled    = 'True'
                LogName      = 'Microsoft-Windows-DnsServer/Analytical'
            }
        )

        $testRuleListSplit = @(
            [ordered]@{
                $($StigRuleGlobal.id + '.a') = @{
                    RuleType    = 'WindowsFeatureRule'
                    DscResource = 'WindowsFeature'
                    Ensure      = 'Present'
                    Name        = 'TestFeature'
                }
                $($StigRuleGlobal.id + '.b') = @{
                    RuleType    = 'RegistryRule'
                    DscResource = 'Registry'
                    Ensure      = 'Present'
                    Key         = 'HKEY_LOCAL_MACHINE\System'
                    ValueData   = 0
                    ValueName   = 'Test'
                    ValueType   = 'Dword'
                }
                CheckContent = "HardCodedRule(WindowsFeatureRule)@{DscResource = 'WindowsFeature'; Ensure = 'Present'; Name = 'TestFeature'}<splitRule>HardCodedRule(RegistryRule)@{DscResource = 'Registry'; Ensure = 'Present'; Key = 'HKEY_LOCAL_MACHINE\System'; ValueData = 0; ValueName = 'Test'; ValueType = 'Dword'}"
            }
        )

        Describe 'Hard Coded Rule Match' {
            It 'Should match and return true' {
                $hardCodedRuleMatch = [HardCodedRuleConvert]::Match($testRuleListSingle[0].CheckContent)
                $hardCodedRuleMatch | Should Be $true
            }
        }


        Describe 'Single Hard Coded Rule' {
            foreach ($testRule in $testRuleListSingle)
            {
                Context "Hard Coded Single Rule: $($testRule.RuleType)" {
                    # Create XML with injected CheckContent
                    $stigRule = Get-TestStigRule -CheckContent $testRule.CheckContent -ReturnGroupOnly
                    $convertedStigRule = [HardCodedRuleConvert]::new($stigRule).AsRule()

                    It "Should convert to $($testRule.RuleType)" {
                        $convertedStigRule.GetType().Name | Should Be $testRule.RuleType
                    }

                    It "Should have correct $($testRule.RuleType) property values defined" {
                        $ruleProperties = $testRule.Clone()
                        $ruleProperties.Remove('RuleType')
                        $ruleProperties.Remove('CheckContent')
                        foreach ($property in $ruleProperties.Keys)
                        {
                            $convertedStigRule.$property | Should Be $testRule[$property]
                        }
                    }
                }
            }
        }

        Describe 'Split Hard Coded Rule' {
            It 'Should have more than one rule (split)' {
                $hardCodedRuleHasMultipleRules = [HardCodedRuleConvert]::HasMultipleRules($testRuleListSplit[0].CheckContent)
                $hardCodedRuleHasMultipleRules | Should Be $true
            }

            foreach ($splitRule in $testRuleListSplit)
            {
                Context "Hard Coded Split Rules (CheckContent): $($splitRule.CheckContent)" {
                    <#
                        Generate XML with a temp check content block.
                        The function will error due to the splitRule being an xml tag,
                        hense the temp check content.
                    #>
                    $stigRule = Get-TestStigRule -CheckContent 'Temp Check Content' -ReturnGroupOnly
                    $stigRule.Rule.check.'check-content' = $splitRule.CheckContent

                    # The HardCodedRuleConvert leverages the SplitFactory class to split Hard Coded Rules.
                    $convertedStigRule = [SplitFactory]::XccdfRule($stigRule, 'HardCodedRuleConvert')

                    $splitRuleCount = ($splitRule.CheckContent -split '\<splitRule\>').Count
                    It "Should have $splitRuleCount split rules" {
                        $convertedStigRule.Count | Should Be $splitRuleCount
                    }

                    $testRuleIds = $splitRule.Keys | Where-Object -FilterScript {$PSItem -ne 'CheckContent'}

                    for ($i = 0; $i -lt $testRuleIds.Count; $i++)
                    {
                        $testRule = $splitRule[$testRuleIds[$i]].Clone()
                        It "Should convert to $($testRule.RuleType)" {
                            $convertedStigRule[$i].GetType().Name | Should Be $testRule.RuleType
                        }

                        It "Should have correct $($testRule.RuleType) property values defined" {
                            $testRule.Remove('RuleType')
                            foreach ($property in $testRule.Keys)
                            {
                                $convertedStigRule[$i].$property | Should Be $testRule[$property]
                            }
                        }
                    }
                }
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
