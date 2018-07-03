# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module .\..\Public\Class\Common.Enum.psm1
using module .\..\Public\Data\Convert.Main.psm1
using module .\..\Public\Class\Convert.Stig.psm1
using module .\Class\accountPolicyRule.psm1
using module .\Class\auditPolicyRule.psm1
using module .\Class\documentRule.psm1
using module .\Class\groupRule.psm1
using module .\Class\manualRule.psm1
using module .\Class\permissionRule.psm1
using module .\Class\registryRule.psm1
using module .\Class\securityOptionRule.psm1
using module .\Class\serviceRule.psm1
using module .\Class\windowsFeatureRule.psm1
using module .\Class\userRightsAssignmentRule.psm1
using module .\Class\wmiRule.psm1
using module .\Class\processMitigationRule.psm1
using module .\Class\dnsServerSettingRule.psm1
using module .\Class\dnsWinEventLogRule.psm1
using module .\Class\dnsServerRootHintRule.psm1
using module .\Class\MimeTypeRule.psm1
using module .\Class\IisLoggingRule.psm1
using module .\Class\WebAppPoolRule.psm1
using module .\Class\WebConfigurationPropertyRule.psm1
using module .\Class\sqlScriptQueryRule.psm1
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
        [System.Collections.ArrayList] $Global:stigsettings = @()
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
