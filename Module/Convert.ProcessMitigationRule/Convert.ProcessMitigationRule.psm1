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
Class ProcessMitigationRule:STIG
{
    [string] $MitigationTarget
    [string] $Enable
    [string] $Disable

    # Constructor
    ProcessMitigationRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetMitigationTargetName ()
    {
        $thisMitigationTargetName = Get-MitigationTargetName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisMitigationTargetName ) )
        {
            $this.set_MitigationTarget( $thisMitigationTargetName )
        }
    }

    [void] SetMitigationToEnable ()
    {
        $thisMitigation = Get-MitigationPolicyToEnable -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisMitigation ) )
        {
            $this.set_Enable( $thisMitigation )
        }
    }

    static [bool] HasMultipleRules ( [string] $MitigationTarget )
    {
        return ( Test-MultipleProcessMitigationRule -MitigationTarget $MitigationTarget )
    }

    static [string[]] SplitMultipleRules ( [string] $MitigationTarget )
    {
        return ( Split-ProcessMitigationRule -MitigationTarget $MitigationTarget )
    }
}
#endregion
