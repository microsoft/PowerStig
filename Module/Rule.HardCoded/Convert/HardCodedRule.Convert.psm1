# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule.AccountPolicy\AccountPolicyRule.psm1
using module .\..\..\Rule.AuditPolicy\AuditPolicyRule.psm1
using module .\..\..\Rule.DnsServerRootHint\DnsServerRootHintRule.psm1
using module .\..\..\Rule.DnsServerSetting\DnsServerSettingRule.psm1
using module .\..\..\Rule.Document\DocumentRule.psm1
using module .\..\..\Rule.FileContent\FileContentRule.psm1
using module .\..\..\Rule.Group\GroupRule.psm1
using module .\..\..\Rule.IISLogging\IISLoggingRule.psm1
using module .\..\..\Rule.Manual\ManualRule.psm1
using module .\..\..\Rule.MimeType\MimeTypeRule.psm1
using module .\..\..\Rule.Permission\PermissionRule.psm1
using module .\..\..\Rule.ProcessMitigation\ProcessMitigationRule.psm1
using module .\..\..\Rule.Registry\RegistryRule.psm1
using module .\..\..\Rule.SecurityOption\SecurityOptionRule.psm1
using module .\..\..\Rule.Service\ServiceRule.psm1
using module .\..\..\Rule.SqlScriptQuery\SqlScriptQueryRule.psm1
using module .\..\..\Rule.UserRight\UserRightRule.psm1
using module .\..\..\Rule.WebAppPool\WebAppPoolRule.psm1
using module .\..\..\Rule.WebConfigurationProperty\WebConfigurationPropertyRule.psm1
using module .\..\..\Rule.WindowsFeature\WindowsFeatureRule.psm1
using module .\..\..\Rule.WinEventLog\WinEventLogRule.psm1
using module .\..\..\Rule.AuditSetting\AuditSettingRule.psm1
using module .\..\..\Rule.SslSettings\SslSettingsRule.psm1
using module .\..\..\Rule.WindowsFeature\Convert\WindowsFeatureRule.Convert.psm1

<#
    .SYNOPSIS
        Identifies and extracts the Hard Coded details from an xccdf rule, that
        has specific replace text defined in the xml log file.
    .DESCRIPTION
        The class is used to convert the rule check-content element into an
        given rule type object. The rule content is parsed to identify it as
        a predefined rule type. The configuration details are then extracted
        and validated before returning the object.
#>
Class HardCodedRuleConvert
{
    [System.Object] $Rule
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    HardCodedRuleConvert ()
    {
    }

    HardCodedRuleConvert ([xml.xmlelement] $XccdfRule)
    {
        $ruleType = Get-HardCodedRuleType -CheckContent $XccdfRule.Rule.Check.'check-content'
        $this.Rule = $this.SetRule($XccdfRule, $ruleType)
    }

    #region Methods

    [object] SetRule ([xml.xmlelement] $XccdfRule, [string] $TypeName)
    {
        $newRule = New-Object -TypeName $TypeName -ArgumentList $XccdfRule
        $propertyHashtable = Get-HardCodedRuleProperty -CheckContent $XccdfRule.Rule.Check.'check-content'
        foreach ($property in $propertyHashtable.Keys)
        {
            $newRule.$property = $propertyHashtable[$property]
        }
        $newRule.set_Severity($XccdfRule.rule.severity)
        $newRule.set_Description($XccdfRule.rule.description)
        $newRule.set_RawString($XccdfRule.Rule.check.'check-content')
        return $newRule
    }

    static [bool] Match ([string] $CheckContent)
    {
        if ($CheckContent -Match 'HardCodedRule')
        {
            return $true
        }
        return $false
    }

    static [bool] HasMultipleRules ([string] $CheckContent)
    {
        $ruleTypeMatch = Get-HardCodedRuleType -CheckContent $CheckContent
        if ($ruleTypeMatch.Count -gt 1)
        {
            return $true
        }

        return $false
    }

    <#
        .SYNOPSIS
            Splits a rule into multiple checks
        .DESCRIPTION
            Once a rule has been found to have multiple checks, the rule needs
            to be split. Each split rule id is appended with a dot and letter
            to keep reporting per the ID consistent. An example would be is
            V-1000 contained 2 checks, then SplitMultipleRules would return 2
            objects with rule ids V-1000.a and V-1000.b
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [string[]] SplitMultipleRules ([string] $CheckContent)
    {
        # TOMORROW ---- NEED TO UPDATE THIS TO RETURN THE RULE TYPE AND RESOURCE INFORMATION -> MAY HAVE TO UPDATE THE REPLACE TEXT AS WELL,
        # AND GET RID OF THE REPEAT CODE IN SPLIT FACTORY THE IF/ELSE
        $ruleTypeMatch = Get-HardCodedRuleType -CheckContent $CheckContent
        return $ruleTypeMatch
    }
    #endregion
}
