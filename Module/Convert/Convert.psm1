using module .\..\Common\Common.psm1
using module .\..\Convert.AccountPolicyRule\Convert.AccountPolicyRule.psm1
using module .\..\Convert.AuditPolicyRule\Convert.AuditPolicyRule.psm1
using module .\..\Convert.DnsServerRootHintRule\Convert.DnsServerRootHintRule.psm1
using module .\..\Convert.DnsServerSettingRule\Convert.DnsServerSettingRule.psm1
using module .\..\Convert.IisLoggingRule\Convert.IisLoggingRule.psm1
using module .\..\Convert.MimeTypeRule\Convert.MimeTypeRule.psm1
using module .\..\Convert.PermissionRule\Convert.PermissionRule.psm1
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
using module .\..\Convert.ProcessMitigationRule\Convert.ProcessMitigationRule.psm1
using module .\..\Convert.GroupRule\Convert.GroupRule.psm1
using module .\..\Convert.FileContentRule\Convert.FileContentRule.psm1
using module .\..\Convert.DocumentRule\Convert.DocumentRule.psm1
using module .\..\Convert.ManualRule\Convert.ManualRule.psm1

class ConvertFactory
{
    static [System.Collections.ArrayList] Rule ([xml.xmlelement] $Rule)
    {
        [System.Collections.ArrayList] $ruleTypeList = @()
        $parsed = $false

        switch ( $Rule.rule.check.'check-content' )
        {
            {[AccountPolicyRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [AccountPolicyRule]::new($Rule) )
                $parsed = $true
            }
            {[AuditPolicyRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [AuditPolicyRule]::new($Rule) )
                $parsed = $true
            }
            {[DnsServerSettingRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [DnsServerSettingRule]::new($Rule) )
                $parsed = $true
            }
            {[DnsServerRootHintRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [DnsServerRootHintRule]::new($Rule) )
                $parsed = $true
            }
            {[IisLoggingRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [IisLoggingRule]::new($Rule) )
                $parsed = $true
            }
            {[MimeTypeRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange( [MimeTypeRule]::ConvertFromXccdf($Rule) )
                $parsed = $true
            }
            {[PermissionRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange( [PermissionRule]::ConvertFromXccdf($Rule) )
                $parsed = $true
            }
            {[RegistryRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange( [RegistryRule]::ConvertFromXccdf($Rule) )
                $parsed = $true
            }
            {[SecurityOptionRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [SecurityOptionRule]::new($Rule) )
                $parsed = $true
            }
            {[ServiceRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange( [ServiceRule]::ConvertFromXccdf($Rule) )
                $parsed = $true
            }
            {[SqlScriptQueryRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [SqlScriptQueryRule]::new($Rule) )
                $parsed = $true
            }
            {[UserRightRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange( [UserRightRule]::ConvertFromXccdf($Rule) )
                $parsed = $true
            }
            {[WebAppPoolRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [WebAppPoolRule]::new($Rule) )
                $parsed = $true
            }
            {[WebConfigurationPropertyRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [WebConfigurationPropertyRule]::new($Rule) )
                $parsed = $true
            }
            {[WindowsFeatureRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange( [WindowsFeatureRule]::ConvertFromXccdf($Rule) )
                $parsed = $true
            }
            {[WinEventLogRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [WinEventLogRule]::new($Rule) )
                $parsed = $true
            }
            {[WmiRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [WmiRule]::new($Rule) )
                $parsed = $true
            }
            {[ProcessMitigationRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [ProcessMitigationRule]::new($Rule) )
                $parsed = $true
            }
            {[GroupRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [GroupRule]::new($Rule) )
                $parsed = $true
            }
            {[FileContentRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.AddRange( [FileContentRule]::ConvertFromXccdf($Rule) )
                $parsed = $true
            }
            {
                <#
                    Break out of switch statement once a rule has been parsed before
                    it tries to convert to a document or manual rule.
                #>
                $parsed -eq $true
            }
            {
                break
            }
            <#
                Some rules have a documentation requirement only for exceptions,
                so the DocumentRule needs to be at the end of the swtich as a
                catch all for documentation rules.
            #>
            {[DocumentRule]::Match($PSItem)}
            {
                $null = $ruleTypeList.Add( [DocumentRule]::new($Rule) )
            }
            default
            {
                $null = $ruleTypeList.Add( [ManualRule]::new($Rule) )
            }
        }

        return $ruleTypeList
    }
}


# function Convert-XccdfRuleList
# {
#     Param ([string] $path)

#     $global:stigRuleGlobal = $stigRule
#     [System.Collections.ArrayList] $global:stigSettings = @()

#     [xml] $xccdf = Get-Content -Path $path

#     foreach ($group in $xccdf.Benchmark.Group)
#     {
#         $rule = [ConvertXccdf]::Rule( $group )

#         if ( $rule.title -match 'Duplicate' -or $exclusionRuleList.Contains(($rule.id -split '\.')[0]) )
#         {
#             [void] $global:stigSettings.Add( ( [DocumentRule]::ConvertFrom( $rule ) ) )
#         }
#         else
#         {
#             [void] $global:stigSettings.Add( $rule )
#         }
#     }

#     return $global:stigSettings
# }
