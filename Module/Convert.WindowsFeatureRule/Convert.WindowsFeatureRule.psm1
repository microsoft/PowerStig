#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
#endregion
#region Class
Class WindowsFeatureRule : STIG
{
    [string]
    $FeatureName

    [string]
    $InstallState

    # Constructor
    WindowsFeatureRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass($StigRule)
    }

    # Methods
    [void] SetFeatureName ()
    {
        $thisFeatureName = Get-WindowsFeatureName -CheckContent $this.RawString

        if ( -not $this.SetStatus( $thisFeatureName ) )
        {
            $this.set_FeatureName( $thisFeatureName )
        }
    }

    [void] SetFeatureInstallState ()
    {
        $thisInstallState = Get-FeatureInstallState -CheckContent $this.RawString

        if ( -not $this.SetStatus( $thisInstallState ) )
        {
            $this.set_InstallState( $thisInstallState )
        }
    }

    static [bool] HasMultipleRules ( [string] $FeatureName )
    {
        return ( Test-MultipleWindowsFeatureRule -FeatureName $FeatureName )
    }

    static [string[]] SplitMultipleRules ( [string] $FeatureName )
    {
        return ( Split-WindowsFeatureRule -FeatureName $FeatureName )
    }
}
#endregion
