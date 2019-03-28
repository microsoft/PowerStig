# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The WindowsFeatureRule class is used to maange the Account Policy Settings.
    .PARAMETER FeatureName
        The windows feature name
    .PARAMETER InstallState
        The state the windows feature should be in
#>
Class WindowsFeatureRule : Rule
{
    [string] $FeatureName
    [string] $InstallState <#(ExceptionValue)#>

    WindowsFeatureRule () {}

    WindowsFeatureRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    WindowsFeatureRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.FeatureName = $Rule.FeatureName
        $this.InstallState = $Rule.InstallState
    }

    [PSObject] GetExceptionHelp()
    {
        if($this.InstallState -eq 'Present')
        {
            $thisInstallState = 'Absent'
        }
        else
        {
            $thisInstallState = 'Present'
        }

        return @{
            Value = $thisInstallState
            Notes = "'Present' and 'Absent' are the only valid values."
        }
    }
}
