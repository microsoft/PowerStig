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
# Header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into an IIS
        Logging object
    .DESCRIPTION
        The IisLoggingRule class is used to extract the IIS Log Settings from
        the check-content of the xccdf. Once a STIG rule is identified as an
        IIS Log rule, it is passed to the IisLoggingRule class for parsing
        and validation.
    .PARAMETER LogCustomFieldEntry

    .PARAMETER LogFlags

    .PARAMETER LogFormat

    .PARAMETER LogPeriod

    .PARAMETER LogTargetW3C

#>
Class IisLoggingRule : STIG
{
    [object[]] $LogCustomFieldEntry
    [string] $LogFlags
    [string] $LogFormat
    [string] $LogPeriod
    [string] $LogTargetW3C

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf stig rule element into a IisLoggingRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    IisLoggingRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    <#
        .SYNOPSIS
            Extracts the log custom field from the check-content and sets the value
        .DESCRIPTION
            Gets the log custom field from the xccdf content and sets the value.
            If the log custom field that is returned is not valid, the parser
            status is set to fail
    #>
    [void] SetLogCustomFields ()
    {
        $thisLogCustomField = Get-LogCustomFieldEntry -CheckContent $this.SplitCheckContent

        $this.set_LogCustomFieldEntry( $thisLogCustomField )
    }

    <#
        .SYNOPSIS
            Extracts the log flag from the check-content and sets the value
        .DESCRIPTION
            Gets the log flag from the xccdf content and sets the value. If the
            log flag that is returned is not valid, the parser status is set
            to fail
    #>
    [void] SetLogFlags ()
    {
        $thisLogFlag = Get-LogFlag -CheckContent $this.SplitCheckContent

        if ( -not [String]::IsNullOrEmpty( $thisLogFlag ) )
        {
            $this.set_LogFlags( $thisLogFlag )
        }
    }

    <#
        .SYNOPSIS
            Extracts the log format from the check-content and sets the value
        .DESCRIPTION
            Gets the log format from the xccdf content and sets the value. If the
            log format that is returned is not valid, the parser status is set
            to fail.
    #>
    [void] SetLogFormat ()
    {
        $thisLogFormat = Get-LogFormat -CheckContent $this.SplitCheckContent

        if ( -not [String]::IsNullOrEmpty( $thisLogFormat ) )
        {
            $this.set_LogFormat( $thisLogFormat )
        }
    }

    <#
        .SYNOPSIS
            Extracts the log period from the check-content and sets the value
        .DESCRIPTION
            Gets the log period from the xccdf content and sets the value. If the
            log period that is returned is not valid, the parser status is set
            to fail.
    #>
    [void] SetLogPeriod ()
    {
        $thisLogPeriod = Get-LogPeriod -CheckContent $this.SplitCheckContent

        if ( -not [String]::IsNullOrEmpty( $thisLogPeriod ) )
        {
            $this.set_LogPeriod( $thisLogPeriod )
        }
    }

    <#
        .SYNOPSIS
            Extracts the log target from the check-content and sets the value
        .DESCRIPTION
            Gets the log target from the xccdf content and sets the value. If the
            log target that is returned is not valid, the parser status is set
            to fail.
    #>
    [void] SetLogTargetW3C ()
    {
        $thisLogTargetW3C = Get-LogTargetW3C -CheckContent $this.SplitCheckContent

        if ( -not [String]::IsNullOrEmpty( $thisLogTargetW3C ) )
        {
            $this.set_LogTargetW3C( $thisLogTargetW3C )
        }
    }

    <#
        .SYNOPSIS
            Validates the parsed data and sets the parser status
        .DESCRIPTION
            Compares the created rule object against and base stig object to
            make sure that all of the properties have be set to valid values.
    #>
    [void] SetStatus ()
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

    #endregion
}
