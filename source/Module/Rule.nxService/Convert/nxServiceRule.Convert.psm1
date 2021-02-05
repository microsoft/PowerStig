# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\nxServiceRule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content and/or fixtext element
        into a Linux Service object.
    .DESCRIPTION
        The nxServiceRuleConvert class is used to extract the Linux Service from
        the check-content of the xccdf. Once a STIG rule is identified as a
        nx Service rule, it is passed to the nxServiceRuleConvert class for
        parsing and validation.
#>
class nxServiceRuleConvert : nxServiceRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory.
    #>
    nxServiceRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf STIG rule element into a nxServiceRule.
        .PARAMETER XccdfRule
            The STIG rule to convert.
    #>
    nxServiceRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $fixText = [nxServiceRule]::GetFixText($XccdfRule)
        $this.SetServiceName($fixText)
        $this.SetServiceEnabled($fixText)
        $this.SetServiceState($fixText)
        if ($this.conversionstatus -eq 'pass')
        {
            $this.SetDuplicateRule()
        }

        $this.SetDscResource()
    }

    <#
        .SYNOPSIS
            Extracts the Service name from the check-content and sets the value.
        .DESCRIPTION
            Gets the Service name from the xccdf content and sets the value. If
            the name that is returned is not valid, the parser status is set to fail.
    #>
    [void] SetServiceName ([string] $FixText)
    {
        $serviceName = Get-nxServiceName -FixText $FixText

        if (-not $this.SetStatus($serviceName))
        {
            $this.set_Name($serviceName)
        }
    }

    <#
        .SYNOPSIS
            Extracts the Service enablement from the check-content and sets the value.
        .DESCRIPTION
            Gets the Service enablement from the xccdf content and sets the value. If
            the enablement returned is not valid, the parser status is set to fail.
    #>
    [void] SetServiceEnabled ([string] $FixText)
    {
        $serviceEnabled = Get-nxServiceEnabled -FixText $FixText

        if (-not $this.SetStatus($serviceEnabled))
        {
            $this.set_Enabled($serviceEnabled)
        }
    }

    <#
        .SYNOPSIS
            Extracts the Service state from the check-content and sets the value.
        .DESCRIPTION
            Gets the Service state from the xccdf content and sets the value. If
            the state that is returned is not valid, the parser status is set to fail.
    #>
    [void] SetServiceState ([string] $FixText)
    {
        if ($this.Enabled -eq $false)
        {
            return
        }

        $serviceState = Get-nxServiceState -FixText $FixText

        if ($this.Enabled -eq $true -and $null -eq $serviceState)
        {
            $serviceState = 'Running'
        }

        if (-not $this.SetStatus($serviceState))
        {
            $this.set_State($serviceState)
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match 'systemctl\s*(is-enabled|is-active|status)' -and
            $CheckContent -Match 'If\s+(?:|the\s+)"\w*".*status.*,\s*this\s*is\s*a\s*finding'
        )
        {
            return $true
        }

        return $false
    }

    <#
        .SYNOPSIS
            Tests if a rule contains multiple checks.
        .DESCRIPTION
            Search the rule text to determine if multiple {0} are defined. For
            possible future use, as of 4.4.0 all STIGs have one Service per rule.
        .PARAMETER Name
            The Service name from the rule text from the check-content element
            in the xccdf.
    #>
    [bool] HasMultipleRules ()
    {
        return $false
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'nxService'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }
}
