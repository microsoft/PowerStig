# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

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
        Extracts the security option from the check-content and sets the value
    .DESCRIPTION
        Gets the security option from the xccdf content and sets the value. If
        the security option that is returned is not valid, the parser status is
        set to fail.
    .PARAMETER OptionName
        The security option name
    .PARAMETER OptionValue
        The security option value
#>
Class SecurityOptionRule : Rule
{
    [ValidateNotNullOrEmpty()] [string] $OptionName
    [ValidateNotNullOrEmpty()] [string] $OptionValue

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf STIG rule element into a SecurityOptionRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    SecurityOptionRule ([xml.xmlelement] $StigRule)
    {
        $this.InvokeClass($StigRule)
        $this.SetOptionName()
        if ($this.TestOptionValueForRange())
        {
            $this.SetOptionValueRange()
        }
        else
        {
            $this.SetOptionValue()
        }
        $this.SetDscResource()
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the security option name from the check-content and sets the value
        .DESCRIPTION
            Gets the security option name from the xccdf content and sets the
            value. If the name that is returned is not valid, the parser status
            is set to fail.
    #>
    [void] SetOptionName ()
    {
        $thisName = Get-SecurityOptionName -CheckContent $this.SplitCheckContent
        if (-not $this.SetStatus($thisName))
        {
            $this.set_OptionName($thisName)
        }
    }

    <#
        .SYNOPSIS
            Checks the string for text that indicates a range of acceptable
            acceptable values are allowed by the STIG.
        .DESCRIPTION
            Checks the string for text that indicates a range of acceptable
            acceptable values are allowed by the STIG.
    #>
    [bool] TestOptionValueForRange ()
    {
        if (Test-SecurityPolicyContainsRange -CheckContent $this.SplitCheckContent)
        {
            return $true
        }

        return $false
    }

    <#
        .SYNOPSIS
            Extracts the security option value from the check-content and sets the value
        .DESCRIPTION
            Gets the security option value from the xccdf content and sets the
            value. If the value that is returned is not valid, the parser status
            is set to fail.
    #>
    [void] SetOptionValue ()
    {
        $thisValue = Get-SecurityOptionValue -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisValue))
        {
            $this.set_OptionValue($thisValue)
        }
    }

    <#
        .SYNOPSIS
            Extracts the security option value range from the check-content and
            sets the organizational test string
        .DESCRIPTION
            Gets the security option value range from the xccdf content and sets
            the organizational test string. If the organizational value that is
            returned is not valid, the parser status is set to fail.
    #>
    [void] SetOptionValueRange ()
    {
        $this.set_OrganizationValueRequired($true)

        $thisPolicyValueTestString = Get-SecurityPolicyOrganizationValueTestString -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisPolicyValueTestString))
        {
            $this.set_OrganizationValueTestString($thisPolicyValueTestString)
        }
    }

    hidden [void] SetDscResource ()
    {
        $this.DscResource = 'SecurityOption'
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            (
                $CheckContent -Match 'gpedit.msc' -and
                $CheckContent -Match 'Security Options'
            )-or
            (
                $CheckContent -Match 'Local Security Policy' -and
                $CheckContent -Match 'Security Options' -and
                $CheckContent -Match 'If the value for'
            )
        )
        {
            return $true
        }
        return $false
    }
    #endregion
}
