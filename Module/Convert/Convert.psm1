# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\AccountPolicyRule\AccountPolicyRule.Covert.psm1
using module .\..\AuditPolicyRule\AuditPolicyRule.psm1
using module .\..\DocumentRule\DocumentRule.psm1
using module .\..\DnsServerRootHintRule\DnsServerRootHintRule.psm1
using module .\..\DnsServerSettingRule\DnsServerSettingRule.psm1
using module .\..\FileContentRule\FileContentRule.psm1
using module .\..\GroupRule\GroupRule.psm1
using module .\..\IISLoggingRule\IISLoggingRule.psm1
using module .\..\ManualRule\ManualRule.psm1
using module .\..\MimeTypeRule\MimeTypeRule.psm1
using module .\..\PermissionRule\PermissionRule.psm1
using module .\..\ProcessMitigationRule\ProcessMitigationRule.psm1
using module .\..\RegistryRule\RegistryRule.psm1
using module .\..\SecurityOptionRule\SecurityOptionRule.psm1
using module .\..\ServiceRule\ServiceRule.psm1
using module .\..\SqlScriptQueryRule\SqlScriptQueryRule.psm1
using module .\..\UserRightsAssignmentRule\UserRightsAssignmentRule.psm1
using module .\..\WebAppPoolRule\WebAppPoolRule.psm1
using module .\..\WebConfigurationPropertyRule\WebConfigurationPropertyRule.psm1
using module .\..\WindowsFeatureRule\WindowsFeatureRule.psm1
using module .\..\WinEventLogRule\WinEventLogRule.psm1
using module .\..\WmiRule\WmiRule.psm1
# Header

class ConvertFactory
{
    static [System.Collections.ArrayList] Rule ([xml.xmlelement] $Rule)
    {
        [System.Collections.ArrayList] $ruleTypeList = @()

        switch ($Rule.rule.check.'check-content')
        {
            {[AccountPolicyRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([AccountPolicyRule]::new($Rule))
            }
            {[AuditPolicyRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([AuditPolicyRule]::new($Rule))
            }
            {[DnsServerSettingRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([DnsServerSettingRule]::new($Rule))
            }
            {[DnsServerRootHintRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add([DnsServerRootHintRule]::new($Rule))
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
