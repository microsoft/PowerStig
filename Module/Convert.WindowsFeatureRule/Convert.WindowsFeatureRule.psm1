# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into a windows
        feature object
    .DESCRIPTION
        The WindowsFeatureRule class is used to extract the windows feature from
        the check-content of the xccdf. Once a STIG rule is identified as a
        windows feature rule, it is passed to the WindowsFeatureRule class for
        parsing and validation.
    .PARAMETER FeatureName
        The windows feature name
    .PARAMETER InstallState
        The state the windows feature should be in
#>
Class WindowsFeatureRule : Rule
{
    [string] $FeatureName
    [string] $InstallState

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf STIG rule element into a WindowsFeatureRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    hidden WindowsFeatureRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass($StigRule)
        $this.SetFeatureName()
        $this.SetFeatureInstallState()
        $this.SetDscResource()

        if ($this.conversionstatus -eq 'pass')
        {
            if ( $this.IsDuplicateRule( $global:stigSettings ))
            {
                $this.SetDuplicateTitle()
            }
        }
    }

    #region Methods

    static [WindowsFeatureRule[]] ConvertFromXccdf ($StigRule)
    {
        $windowsFeatureRule = [WindowsFeatureRule]::new($StigRule)

        if ( [WindowsFeatureRule]::HasMultipleRules( $windowsFeatureRule.FeatureName ) )
        {
            $firstElement = $true
            [int] $byte = 97
            $windowsFeatureRules = @()
            $tempRule = $windowsFeatureRule.Clone()
            [string[]] $splitRules = [WindowsFeatureRule]::SplitMultipleRules( $windowsFeatureRule.FeatureName )

            foreach ( $windowsFeatureName in $splitRules )
            {
                if ( $firstElement )
                {
                    $windowsFeatureRule.FeatureName = $windowsFeatureName
                    $windowsFeatureRule.id = "$($windowsFeatureRule.id).$([CHAR][BYTE]$byte)"
                    $windowsFeatureRules += $windowsFeatureRule
                    $firstElement = $false
                }
                else
                {
                    $newRule = $tempRule.Clone()
                    $newRule.FeatureName = $windowsFeatureName
                    $newRule.id = "$($newRule.id).$([CHAR][BYTE]$byte)"
                    $windowsFeatureRules += $newRule
                    [void] $global:stigSettings.Add($newRule)
                }
                $byte++
            }
            return $windowsFeatureRules
        }
        else
        {
            return $windowsFeatureRule
        }
    }

    <#
        .SYNOPSIS
            Extracts the feature name from the check-content and sets the value
        .DESCRIPTION
            Gets the feature name from the xccdf content and sets the value. If
            the name that is returned is not valid, the parser status is set to fail.
    #>
    [void] SetFeatureName ()
    {
        $thisFeatureName = Get-WindowsFeatureName -CheckContent $this.RawString

        if ( -not $this.SetStatus( $thisFeatureName ) )
        {
            $this.set_FeatureName( $thisFeatureName )
        }
    }

    <#
        .SYNOPSIS
            Extracts the feature state from the check-content and sets the value
        .DESCRIPTION
            Gets the feature state from the xccdf content and sets the value. If
            the state that is returned is not valid, the parser status is set to fail.
    #>
    [void] SetFeatureInstallState ()
    {
        $thisInstallState = Get-FeatureInstallState -CheckContent $this.RawString

        if ( -not $this.SetStatus( $thisInstallState ) )
        {
            $this.set_InstallState( $thisInstallState )
        }
    }

    static [bool] Match ( [string] $CheckContent )
    {
        if
        (
            $CheckContent -Match '(Get-Windows(Optional)?Feature|is not installed by default)' -or
            $CheckContent -Match 'WebDAV Authoring Rules' -and
            $CheckContent -NotMatch 'HKEY_LOCAL_MACHINE'
        )
        {
            return $true
        }
        return $false
    }

    <#
        .SYNOPSIS
            Tests if a rule contains multiple checks
        .DESCRIPTION
            Search the rule text to determine if multiple {0} are defined
        .PARAMETER FeatureName
            The feature name from the rule text from the check-content element
            in the xccdf
    #>
    static [bool] HasMultipleRules ( [string] $FeatureName )
    {
        return ( Test-MultipleWindowsFeatureRule -FeatureName $FeatureName )
    }

    <#
        .SYNOPSIS
            Splits a rule into multiple checks
        .DESCRIPTION
            Once a rule has been found to have multiple checks, the rule needs
            to be split. This method splits a windows feature into multiple rules.
            Each split rule id is appended with a dot and letter to keep reporting
            per the ID consistent. An example would be is V-1000 contained 2
            checks, then SplitMultipleRules would return 2 objects with rule ids
            V-1000.a and V-1000.b
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [string[]] SplitMultipleRules ( [string] $FeatureName )
    {
        return ( Split-WindowsFeatureRule -FeatureName $FeatureName )
    }

    hidden [void] SetDscResource ()
    {
        $this.DscResource = 'WindowsOptionalFeature'
    }
    #endregion
}
