# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module .\..\public\Class\StigClass.psm1
using module .\common\accountPolicyRule.psm1
using module .\common\auditPolicyRule.psm1
using module .\common\documentRule.psm1
using module .\common\groupRule.psm1
using module .\common\manualRule.psm1
using module .\common\permissionRule.psm1
using module .\common\registryRule.psm1
using module .\common\securityOptionRule.psm1
using module .\common\serviceRule.psm1
using module .\common\windowsFeatureRule.psm1
using module .\common\userRightsAssignmentRule.psm1
using module .\common\wmiRule.psm1
using module .\common\processMitigationRule.psm1
using module .\dns_server\dnsServerSettingRule.psm1
using module .\dns_server\dnsWinEventLogRule.psm1
using module .\dns_server\dnsServerRootHintRule.psm1
using module .\iis\MimeTypeRule.psm1
using module .\iis\IisLoggingRule.psm1
using module .\iis\WebAppPoolRule.psm1
using module .\iis\WebConfigurationPropertyRule.psm1
using module .\sql\sqlScriptQueryRule.psm1
using module .\..\public\common\enum.psm1
. $PSScriptRoot\..\public\common\data.ps1
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
