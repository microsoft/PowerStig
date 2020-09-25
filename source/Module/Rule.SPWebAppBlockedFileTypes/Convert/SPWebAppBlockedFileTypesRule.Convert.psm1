# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\SPWebAppBlockedFileTypesRule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}

# Header

<#
    .SYNOPSIS
        Identifies and extracts the Security Option details from an xccdf rule.
    .DESCRIPTION
        The class is used to convert the rule check-content element into an
        Security Option object. The rule content is parsed to identify it as a
        Security Option rule. The configuration details are then extracted and
        validated before returning the object.
#>
class SPWebAppBlockedFileTypesRuleConvert : SPWebAppBlockedFileTypesRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SPWebAppBlockedFileTypesRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SharePoint Diagnostic provider Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    SPWebAppBlockedFileTypesRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetSPWebAppBlockedFileTypes()
        $this.SetDuplicateRule()
        $this.SetDscResource()
    }

    #region Methods

    [void] SetSPWebAppBlockedFileTypes()
    {
        if ($this.OrgRuleContainsRange())
        {
            $this.SetOrganizationValue()
        }
    }
    
    [bool] OrgRuleContainsRange ()
    {
        if (Test-OrgRuleRange -CheckContent $this.SplitCheckContent)
        {
            return $true
        }
        return $false
    }

    [void] SetOrganizationValue ()
    {
        $this.set_OrganizationValueRequired($true)

        $thisValueTestString = "'{0}' 'matches the `"blacklist`" document in the application's SSP'"

        if (-not $this.SetStatus($thisValueTestString))
        {
            $this.set_OrganizationValueTestString($thisValueTestString)
        }
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'SPWebAppBlockedFileTypes'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }

    <#
        .SYNOPSIS
            looks for keywords that represent the correct rule
        .DESCRIPTION
            Is used to match this rule to the apporpriate STIG at compile time
    #>

    
#(($CheckContent -Match "Public URL for zone") -or (($CheckContent -match "https, this is a finding.") -and ($CheckContent -Match "SharePoint Server")))


    static [bool] Match ([string] $CheckContent)
    {
        if(($CheckContent -Match "SharePoint Server") -and ($CheckContent -match ".*blocked file types.* SSP. If the SSP .* blocked file types list, this is a finding."))
        {
            return $true
        }
        return $false
    }
    #endregion
}
