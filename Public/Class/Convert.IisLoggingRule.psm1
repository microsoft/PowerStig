#region Header V1
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\Common.Enum.psm1
using module .\Convert.Stig.psm1
using module .\..\Data\Convert.Data.psm1
# Additional required modules

#endregion
#region Class Definition
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
#region Method Functions

<#
.SYNOPSIS
    Returns the log format.

.Parameter CheckContent
    An array of the raw string data taken from the STIG setting.
#>
function Get-LogCustomFieldEntry
{
    [CmdletBinding()]
    [OutputType([object[]])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    if ($CheckContent -match $script:webRegularExpression.customFieldSection)
    {
        $customFieldEntries = @()
        [string[]] $customFieldMatch = $CheckContent | Select-String -Pattern $script:webRegularExpression.customFields -AllMatches

        foreach ($customField in $customFieldMatch)
        {
            $customFieldEntry = ($customField -split $script:webRegularExpression.customFields).trim()
            $customFieldEntries += @{
                SourceType = $customFieldEntry[0] -replace ' ', ''
                SourceName = $customFieldEntry[1]
            }
        }
    }

    return $customFieldEntries
}

<#
.SYNOPSIS
    Returns the log flags.

.Parameter CheckContent
    An array of the raw string data taken from the STIG setting.
#>
function Get-LogFlag
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $cleanCheckContent = $CheckContent -replace $script:webRegularExpression.excludeExtendedAscii, ''

    switch ($cleanCheckContent)
    {
        { $PSItem -match $script:webRegularExpression.logFlags }
        {
            $logFlagString = $cleanCheckContent | Select-String -Pattern $script:webRegularExpression.logFlags -AllMatches
            $logFlagValue = Get-LogFlagValue -LogFlags ($logFlagString.Matches.groups.value -split ',')
        }
        { $PSItem -match $script:webRegularExpression.standardFields }
        {
            [string] $logFlagLine = $cleanCheckContent | Select-String -Pattern $script:webRegularExpression.standardFields -AllMatches
            $logFlagString = $logFlagLine | Select-String -Pattern $script:webRegularExpression.standardFieldEntries -AllMatches
            $logFlagValue = Get-LogFlagValue -LogFlags ( $logFlagString.Matches.Groups.Where{$PSItem.name -eq 1}.value )
        }
    }

    return $logFlagValue
}

<#
.SYNOPSIS
    Returns the log format.

.Parameter CheckContent
    An array of the raw string data taken from the STIG setting.
#>
function Get-LogFormat
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    [string] $logFormatLine = $CheckContent | Select-String -Pattern $script:webRegularExpression.logformat -AllMatches

    if (-not [String]::IsNullOrEmpty( $logFormatLine ))
    {
        $logFormat = $logFormatLine | Select-String -Pattern $script:webRegularExpression.keyValuePair -AllMatches
        return $logFormat.Matches.Groups.value[-1]
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] No log format found"
        return $null
    }
}

<#
.SYNOPSIS
    Returns the log roll over period.

.Parameter CheckContent
    An array of the raw string data taken from the STIG setting.
#>
function Get-LogPeriod
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    switch ( $CheckContent )
    {
        { $PsItem -match $script:webRegularExpression.logperiod }
        {
            return 'daily'
        }
    }
}

<#
.SYNOPSIS
    Returns the log event target.

.Parameter CheckContent
    An array of the raw string data taken from the STIG setting.
#>
function Get-LogTargetW3C
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    [string] $logTargetW3cLine = $CheckContent | Select-String -Pattern $script:webRegularExpression.logtargetw3c -AllMatches

    if (-not [String]::IsNullOrEmpty( $logTargetW3cLine ))
    {
        $logTargetW3C = $logTargetW3cLine | Select-String -Pattern $script:webRegularExpression.keyValuePair -AllMatches

        switch ( $logTargetW3C.Matches.Groups.value )
        {
            { $PSItem -match 'Both log file and ETW event'}
            {
                return 'File,ETW'
            }
        }
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] No log event target found"
        return $null
    }
}

<#
.SYNOPSIS
    Translates and returns the log flag constants

.PARAMETER LogFlags
    Array of log flags
#>
function Get-LogFlagValue
{
    [CmdletBinding()]
    [OutputType([string[]])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $LogFlags
    )

    $logFlagReturn = @()

    foreach ($flag in $LogFlags)
    {
        $logFlagReturn += $script:logflagsConstant.($flag.trim())
    }

    return $logFlagReturn.where{ -not [string]::IsNullOrEmpty($PSItem) } -join ','
}
#endregion
