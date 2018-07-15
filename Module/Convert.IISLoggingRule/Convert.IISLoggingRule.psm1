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
Class IisLoggingRule : STIG
{
    [object[]] $LogCustomFieldEntry
    [string] $LogFlags
    [string] $LogFormat
    [string] $LogPeriod
    [string] $LogTargetW3C

    # Constructors
    IisLoggingRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    [void] SetLogCustomFields ( )
    {
        $thisLogCustomField = Get-LogCustomFieldEntry -CheckContent $this.SplitCheckContent

        $this.set_LogCustomFieldEntry( $thisLogCustomField )
    }

    [void] SetLogFlags ( )
    {
        $thisLogFlag = Get-LogFlag -CheckContent $this.SplitCheckContent

        if ( -not [String]::IsNullOrEmpty( $thisLogFlag ) )
        {
            $this.set_LogFlags( $thisLogFlag )
        }
    }

    [void] SetLogFormat ( )
    {
        $thisLogFormat = Get-LogFormat -CheckContent $this.SplitCheckContent

        if ( -not [String]::IsNullOrEmpty( $thisLogFormat ) )
        {
            $this.set_LogFormat( $thisLogFormat )
        }
    }

    [void] SetLogPeriod ( )
    {
        $thisLogPeriod = Get-LogPeriod -CheckContent $this.SplitCheckContent

        if ( -not [String]::IsNullOrEmpty( $thisLogPeriod ) )
        {
            $this.set_LogPeriod( $thisLogPeriod )
        }
    }

    [void] SetLogTargetW3C ( )
    {
        $thisLogTargetW3C = Get-LogTargetW3C -CheckContent $this.SplitCheckContent

        if ( -not [String]::IsNullOrEmpty( $thisLogTargetW3C ) )
        {
            $this.set_LogTargetW3C( $thisLogTargetW3C )
        }
    }

    [void] SetStatus ( )
    {
        $baseStig = [Stig]::New()
        $referenceProperties = ( $baseStig | Get-Member -MemberType Property ).Name
        $differenceProperties = ( $this | Get-Member -MemberType Property ).Name
        $propertyList = (Compare-Object -ReferenceObject $referenceProperties -DifferenceObject $differenceProperties).InputObject

        $status = $false

        foreach ($property in $propertyList)
        {
            if ( $null -ne $this.$property )
            {
                $status = $true
            }
        }

        if (-not $status)
        {
            $this.conversionstatus = [status]::fail
        }
    }
}
#endregion
