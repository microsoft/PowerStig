# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Rule\Convert.Rule.psm1

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
    WindowsFeatureRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass($StigRule)
    }

    #region Methods

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

    #endregion
}
