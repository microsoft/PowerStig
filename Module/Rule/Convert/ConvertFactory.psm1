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

class SplitFactory
{
    <#
        .SYNOPSIS
            Static method split
    #>
    static [System.Collections.ArrayList] XccdfRule ([xml.xmlelement] $Rule, [string] $TypeName)
    {
        [System.Collections.ArrayList] $ruleList = @()

        $instance = New-Object -TypeName $TypeName
        $hasMultipleRules = $instance.GetType().GetMethod('HasMultipleRules')

        if (-not $hasMultipleRules.IsStatic)
        {
            throw "$TypeName does not have a static HasMultipleRules method"
        }

        if ($HasMultipleRules.Invoke($HasMultipleRules, $Rule.rule.Check.'check-content'))
        {
            $splitMultipleRules = $instance.GetType().GetMethod('SplitMultipleRules')
            [string[]] $splitRules = $splitMultipleRules.Invoke($splitMultipleRules, $Rule.rule.Check.'check-content')
            foreach ($splitRule in $splitRules)
            {
                $Rule.rule.Check.'check-content' = $splitRule
                $ruleList += (New-Object -TypeName $TypeName -ArgumentList $Rule).AsRule()
            }
        }
        else
        {
            $ruleList += (New-Object -TypeName $TypeName -ArgumentList $Rule).AsRule()
        }
        return $ruleList
    }

    <#
        .SYNOPSIS
            Instance method split
    #>
    static [System.Collections.ArrayList] XccdfRule ([psobject] $Rule, [string] $TypeName, [string] $Property)
    {
        [System.Collections.ArrayList] $ruleList = @()

        $instance = New-Object -TypeName $TypeName -ArgumentList $Rule
        if ($instance.HasMultipleRules())
        {
            [string[]] $splitRules = $instance.SplitMultipleRules()
            foreach ($splitRule in $splitRules)
            {
                $ruleClone = $instance.Clone()
                $ruleClone.$Property = $splitRule
                $ruleList += $ruleClone.AsRule()
            }
        }
        else
        {
            $ruleList += $instance.AsRule()
        }
        return $ruleList
    }
}

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
                        [SplitFactory]::XccdfRule($Rule, 'FileContentRuleConvert')
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
                    [SplitFactory]::XccdfRule($Rule, 'MimeTypeRuleConvert')
                )
            }
            {[PermissionRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [SplitFactory]::XccdfRule($Rule, 'PermissionRuleConvert')
                )
            }
            {[ProcessMitigationRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [SplitFactory]::XccdfRule($Rule, 'ProcessMitigationRuleConvert', 'MitigationTarget')
                )
            }
            {[RegistryRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [SplitFactory]::XccdfRule($Rule, 'RegistryRuleConvert')
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
                    [SplitFactory]::XccdfRule($Rule, 'ServiceRuleConvert', 'ServiceName')
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
                    [SplitFactory]::XccdfRule($Rule, 'UserRightRuleConvert')
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
                    [SplitFactory]::XccdfRule($Rule, 'WebConfigurationPropertyRuleConvert')
                )
            }
            {[WindowsFeatureRuleConvert]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange(
                    [SplitFactory]::XccdfRule($Rule, 'WindowsFeatureRuleConvert', 'FeatureName')
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

         <# 
         Rules can be split into multiple rules of multiple types, so the list
         of Id's needs to be validated to be unique.
         #>
        $ruleCount = ($ruleTypeList | Measure-Object).count
        $uniqueRuleCount = ($ruleTypeList |
            Select-Object -Property Id -Unique |
                Measure-Object).count

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
