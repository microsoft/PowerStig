# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule.AccountPolicy\Convert\AccountPolicyRule.Convert.psm1
using module .\..\..\Rule.AuditPolicy\Convert\AuditPolicyRule.Convert.psm1
using module .\..\..\Rule.DnsServerRootHint\Convert\DnsServerRootHintRule.Convert.psm1
using module .\..\..\Rule.DnsServerSetting\Convert\DnsServerSettingRule.Convert.psm1
using module .\..\..\Rule.Document\Convert\DocumentRule.Convert.psm1
using module .\..\..\Rule.FileContent\Convert\FileContentRule.Convert.psm1
using module .\..\..\Rule.Group\Convert\GroupRule.Convert.psm1
using module .\..\..\Rule.IISLogging\Convert\IISLoggingRule.Convert.psm1
using module .\..\..\Rule.Manual\Convert\ManualRule.Convert.psm1
using module .\..\..\Rule.MimeType\Convert\MimeTypeRule.Convert.psm1
using module .\..\..\Rule.Permission\Convert\PermissionRule.Convert.psm1
using module .\..\..\Rule.ProcessMitigation\Convert\ProcessMitigationRule.Convert.psm1
using module .\..\..\Rule.Registry\Convert\RegistryRule.Convert.psm1
using module .\..\..\Rule.SecurityOption\Convert\SecurityOptionRule.Convert.psm1
using module .\..\..\Rule.Service\Convert\ServiceRule.Convert.psm1
using module .\..\..\Rule.SqlScriptQuery\Convert\SqlScriptQueryRule.Convert.psm1
using module .\..\..\Rule.UserRight\Convert\UserRightRule.Convert.psm1
using module .\..\..\Rule.WebAppPool\Convert\WebAppPoolRule.Convert.psm1
using module .\..\..\Rule.WebConfigurationProperty\Convert\WebConfigurationPropertyRule.Convert.psm1
using module .\..\..\Rule.WindowsFeature\Convert\WindowsFeatureRule.Convert.psm1
using module .\..\..\Rule.WinEventLog\Convert\WinEventLogRule.Convert.psm1
using module .\..\..\Rule.Wmi\Convert\WmiRule.Convert.psm1
# Header

class ConvertFactory
{
    static [System.Collections.ArrayList] Rule ([xml.xmlelement] $Rule)
    {
        [System.Collections.ArrayList] $ruleTypeList = @()

        switch ($Rule.rule.check.'check-content')
        {
            {[AccountPolicyRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [AccountPolicyRuleConvert]::new($Rule).AsRule()
                )
            }
            {[AuditPolicyRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [AuditPolicyRuleConvert]::new($Rule).AsRule()
                )
            }
            {[DnsServerSettingRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [DnsServerSettingRuleConvert]::new($Rule).AsRule()
                )
            }
            {[DnsServerRootHintRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [DnsServerRootHintRuleConvert]::new($Rule).AsRule()
                )
            }
            {[FileContentRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [FileContentRuleConvert]::ConvertFromXccdf($Rule)
                )
            }
            {[GroupRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [GroupRuleConvert]::new($Rule).AsRule()
                )
            }
            {[IisLoggingRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [IisLoggingRuleConvert]::new($Rule).AsRule()
                )
            }
            {[MimeTypeRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [MimeTypeRuleConvert]::ConvertFromXccdf($Rule)
                )
            }
            {[PermissionRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [PermissionRuleConvert]::ConvertFromXccdf($Rule)
                )
            }
            {[ProcessMitigationRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [ProcessMitigationRuleConvert]::ConvertFromXccdf($Rule)
                )
            }
            {[RegistryRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [RegistryRuleConvert]::ConvertFromXccdf($Rule)
                )
            }
            {[SecurityOptionRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [SecurityOptionRuleConvert]::new($Rule).AsRule()
                )
            }
            {[ServiceRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [ServiceRuleConvert]::ConvertFromXccdf($Rule)
                )
            }
            {[SqlScriptQueryRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [SqlScriptQueryRuleConvert]::new($Rule).AsRule()
                )
            }
            {[UserRightRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [UserRightRuleConvert]::ConvertFromXccdf($Rule)
                )
            }
            {[WebAppPoolRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [WebAppPoolRuleConvert]::new($Rule).AsRule()
                )
            }
            {[WebConfigurationPropertyRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [WebConfigurationPropertyRuleConvert]::ConvertFromXccdf($Rule)
                )
            }
            {[WindowsFeatureRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [WindowsFeatureRuleConvert]::ConvertFromXccdf($Rule)
                )
            }
            {[WinEventLogRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [WinEventLogRuleConvert]::new($Rule).AsRule()
                )
            }
            {[WmiRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add(
                    [WmiRuleConvert]::new($Rule).AsRule()
                )
            }
            <#
                Some rules have a documentation requirement only for exceptions,
                so the DocumentRule needs to be at the end of the switch as a
                catch all for documentation rules. Once a rule has been parsed,
                it should not be converted into a document rule.
            #>
            {[DocumentRuleConvert]::Match($PSItem) -and $ruleTypeList.Count -eq 0}
            {
                $null = $ruleTypeList.Add(
                    [DocumentRuleConvert]::new($Rule).AsRule()
                )
            }
            default
            {
                $null = $ruleTypeList.Add(
                    [ManualRuleConvert]::new($Rule).AsRule()
                )
            }
        }

        # Rules can be split into multiple rules of multiple types, so the list
        # of Id's needs to be validated to be unique.
        $ruleCount = ($ruleTypeList | Measure-Object).count
        $uniqueRuleCount = ($ruleTypeList | Select-Object -Property Id -Unique | Measure-Object).count

        if ($uniqueRuleCount -ne $ruleCount)
        {
            [int] $byte = 97 # Lowercase A
            foreach ($convertedrule in $ruleTypeList)
            {
                $convertedrule.id = "$($Rule.id).$([CHAR][BYTE]$byte)"
                $byte ++
            }
        }

        return $ruleTypeList
    }
}
