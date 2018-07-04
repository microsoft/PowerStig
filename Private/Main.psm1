# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module .\..\Public\Class\Common.Enum.psm1
using module .\..\Public\Data\Convert.Data.psm1
using module .\..\Public\Class\Convert.Stig.psm1
using module .\Class\Convert.AccountPolicyRule.psm1
using module .\Class\Convert.AuditPolicyRule.psm1
using module .\Class\Convert.DnsServerSettingRule.psm1
using module .\Class\Convert.DnsWinEventLogRule.psm1
using module .\Class\Convert.DnsServerRootHintRule.psm1
using module .\Class\Convert.DocumentRule.psm1
using module .\Class\Convert.GroupRule.psm1
using module .\Class\Convert.IISLoggingRule.psm1
using module .\Class\Convert.ManualRule.psm1
using module .\Class\Convert.MimeTypeRule.psm1
using module .\Class\Convert.PermissionRule.psm1
using module .\Class\Convert.ProcessMitigationRule.psm1
using module .\Class\Convert.RegistryRule.psm1
using module .\Class\Convert.SecurityOptionRule.psm1
using module .\Class\Convert.ServiceRule.psm1
using module .\Class\Convert.SqlScriptQueryRule.psm1
using module .\Class\Convert.UserRightsAssignmentRule.psm1
using module .\Class\Convert.WebAppPoolRule.psm1
using module .\Class\Convert.WebConfigurationPropertyRule.psm1
using module .\Class\Convert.WindowsFeatureRule.psm1
using module .\Class\Convert.WmiRule.psm1
#endregion Header

#region Main Functions

<#
    .SYNOPSIS
        Get-StigRules determines what type of STIG setting is being processed and sends it to a
        specalized function for additional processing.
    .DESCRIPTION
        Get-StigRules pre-sorts the STIG rules that is recieves and tries to determine what type
        of object it should create. For example if the check content has the string HKEY, it assumes
        that the setting is a registry object and sends the check to the registry sub functions to
        further break down the string into a registry object.
    .PARAMETER StigGroups
        An array of the child STIG Group elements from the parent Benchmark element in the xccdf.
    .PARAMETER IncludeRawString
        A flag that returns the unaltered Check-Content with the converted object.
    .NOTES
        General notes
#>
function Get-StigRules
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [psobject]
        $StigGroups,

        [parameter()]
        [switch]
        $IncludeRawString
    )

    begin
    {
        [System.Collections.ArrayList] $Global:stigSettings = @()
        [int] $stigGroupCount = $StigGroups.Count
        [int] $stigProcessedCounter = 1
    }
    process
    {
        foreach ( $stigRule in $StigGroups )
        {
            # Global added so that the stig rule can be referenced later
            $Global:stigRuleGlobal = $stigRule
            $informationParameters = @{
                MessageData       = "INFO: [$stigProcessedCounter of $stigGroupCount] $($stigRule.id)"
                InformationAction = 'Continue'
            }

            Write-Information @informationParameters
            $ruleTypes = [STIG]::GetRuleTypeMatchList( $stigRule.rule.Check.('check-content') )
            foreach ( $ruleType in $ruleTypes )
            {
                $rules = & "ConvertTo-$ruleType" -StigRule $stigRule

                foreach ( $rule in $rules )
                {
                    if ( $rule.title -match 'Duplicate' -or $exclusionRuleList.Contains(($rule.id -split '\.')[0]) )
                    {
                        [void] $Global:StigSettings.Add( ( [DocumentRule]::ConvertFrom( $rule ) ) )
                    }
                    else
                    {
                        [void] $Global:stigsettings.Add( $rule )
                    }
                }
                # Increment the counter to update the console output
                $stigProcessedCounter ++
            }
        }
    }
    end
    {
        $Global:stigsettings
    }
}
#endregion Main Functions
