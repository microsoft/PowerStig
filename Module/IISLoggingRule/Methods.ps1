# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
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
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    if ($checkContent -match $RegularExpression.customFieldSection)
    {
        $customFieldEntries = @()
        [string[]] $customFieldMatch = $checkContent | Select-String -Pattern $RegularExpression.customFields -AllMatches

        foreach ($customField in $customFieldMatch)
        {
            $customFieldEntry = ($customField -split $RegularExpression.customFields).trim()
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
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $cleanCheckContent = $checkContent -replace ([RegularExpression]::excludeExtendedAscii), ''

    switch ($cleanCheckContent)
    {
        { $PSItem -match $RegularExpression.logFlags }
        {
            $logFlagString = $cleanCheckContent | Select-String -Pattern $RegularExpression.logFlags -AllMatches
            $logFlagValue = Get-LogFlagValue -LogFlags ($logFlagString.Matches.groups.value -split ',')
        }
        { $PSItem -match $RegularExpression.standardFields }
        {
            [string] $logFlagLine = $cleanCheckContent | Select-String -Pattern $RegularExpression.standardFields -AllMatches
            $logFlagString = $logFlagLine | Select-String -Pattern $RegularExpression.standardFieldEntries -AllMatches
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
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    [string] $logFormatLine = $checkContent | Select-String -Pattern $RegularExpression.logFormat -AllMatches

    if (-not [String]::IsNullOrEmpty( $logFormatLine ))
    {
        $logFormat = $logFormatLine | Select-String -Pattern ([RegularExpression]::KeyValuePair) -AllMatches
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
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    switch ( $checkContent )
    {
        { $PsItem -match $RegularExpression.logperiod }
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
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    [string] $logTargetW3cLine = $checkContent | Select-String -Pattern $RegularExpression.logtargetw3c -AllMatches

    if (-not [String]::IsNullOrEmpty( $logTargetW3cLine ))
    {
        $logTargetW3C = $logTargetW3cLine | Select-String -Pattern ([RegularExpression]::KeyValuePair) -AllMatches

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
    param
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
