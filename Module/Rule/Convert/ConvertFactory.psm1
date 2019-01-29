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
            {[FileContentRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange([FileContentRule]::ConvertFromXccdf($Rule))
            }
            {[GroupRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([GroupRule]::new($Rule))
            }
            {[IisLoggingRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([IisLoggingRule]::new($Rule))
            }
            {[MimeTypeRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange([MimeTypeRule]::ConvertFromXccdf($Rule))
            }
            {[PermissionRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange([PermissionRule]::ConvertFromXccdf($Rule))
            }
            {[ProcessMitigationRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange([ProcessMitigationRule]::ConvertFromXccdf($Rule))
            }
            {[RegistryRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange([RegistryRule]::ConvertFromXccdf($Rule))
            }
            {[SecurityOptionRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([SecurityOptionRule]::new($Rule))
            }
            {[ServiceRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange([ServiceRule]::ConvertFromXccdf($Rule))
            }
            {[SqlScriptQueryRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([SqlScriptQueryRule]::new($Rule))
            }
            {[UserRightRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange([UserRightRule]::ConvertFromXccdf($Rule))
            }
            {[WebAppPoolRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([WebAppPoolRule]::new($Rule))
            }
            {[WebConfigurationPropertyRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange([WebConfigurationPropertyRule]::ConvertFromXccdf($Rule))
            }
            {[WindowsFeatureRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange([WindowsFeatureRule]::ConvertFromXccdf($Rule))
            }
            {[WinEventLogRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([WinEventLogRule]::new($Rule))
            }
            {[WmiRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([WmiRule]::new($Rule))
            }
            <#
                Some rules have a documentation requirement only for exceptions,
                so the DocumentRule needs to be at the end of the switch as a
                catch all for documentation rules. Once a rule has been parsed,
                it should not be converted into a document rule.
            #>
            {[DocumentRule]::Match($PSItem) -and $ruleTypeList.Count -eq 0}
            {
                $null = $ruleTypeList.Add([DocumentRule]::new($Rule))
            }
            default
            {
                $null = $ruleTypeList.Add([ManualRule]::new($Rule))
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
