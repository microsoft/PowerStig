using module .\..\Common\Common.psm1
using module .\..\AccountPolicyRule\AccountPolicyRule.psm1
using module .\..\Convert.AuditPolicyRule\Convert.AuditPolicyRule.psm1
using module .\..\Convert.DocumentRule\Convert.DocumentRule.psm1
using module .\..\Convert.DnsServerRootHintRule\Convert.DnsServerRootHintRule.psm1
using module .\..\Convert.DnsServerSettingRule\Convert.DnsServerSettingRule.psm1
using module .\..\Convert.FileContentRule\Convert.FileContentRule.psm1
using module .\..\Convert.GroupRule\Convert.GroupRule.psm1
using module .\..\Convert.IisLoggingRule\Convert.IisLoggingRule.psm1
using module .\..\Convert.ManualRule\Convert.ManualRule.psm1
using module .\..\Convert.MimeTypeRule\Convert.MimeTypeRule.psm1
using module .\..\Convert.PermissionRule\Convert.PermissionRule.psm1
using module .\..\Convert.ProcessMitigationRule\Convert.ProcessMitigationRule.psm1
using module .\..\Convert.RegistryRule\Convert.RegistryRule.psm1
using module .\..\Convert.SecurityOptionRule\Convert.SecurityOptionRule.psm1
using module .\..\Convert.ServiceRule\Convert.ServiceRule.psm1
using module .\..\Convert.SqlScriptQueryRule\Convert.SqlScriptQueryRule.psm1
using module .\..\Convert.UserRightsAssignmentRule\Convert.UserRightsAssignmentRule.psm1
using module .\..\Convert.WebAppPoolRule\Convert.WebAppPoolRule.psm1
using module .\..\Convert.WebConfigurationPropertyRule\Convert.WebConfigurationPropertyRule.psm1
using module .\..\Convert.WindowsFeatureRule\Convert.WindowsFeatureRule.psm1
using module .\..\Convert.WinEventLogRule\Convert.WinEventLogRule.psm1
using module .\..\Convert.WmiRule\Convert.WmiRule.psm1

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
