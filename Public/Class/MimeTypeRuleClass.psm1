# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module .\StigClass.psm1
using module ..\common\enum.psm1
. $PSScriptRoot\..\data\data.Web.ps1
#endregion
#region Class Definition
Class MimeTypeRule : STIG
{
    [string] $Extension
    [string] $MimeType
    [string] $Ensure

    # Constructors
    MimeTypeRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetExtension ( )
    {
        $thisExtension = Get-Extension -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisExtension ) )
        {
            $this.set_Extension( $thisExtension )
        }
    }

    [void] SetMimeType ( )
    {
        $thisMimeType = Get-MimeType -Extension $this.Extension

        if ( -not $this.SetStatus( $thisMimeType ) )
        {
            $this.set_MimeType( $thisMimeType )
        }
    }

    [void] SetEnsure ( )
    {
        $thisEnsure = Get-Ensure -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisEnsure ) )
        {
            $this.set_Ensure( $thisEnsure )
        }
    }

    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        return Test-MultipleMimeTypeRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) )
    }

    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleMimeTypeRule -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
    }

}
#endregion
#region Method Functions
<#
.SYNOPSIS
    Returns the Extension for the STIG rule.

.Parameter CheckContent
    An array of the raw string data taken from the STIG setting.
#>
function Get-Extension
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $mimeTypeMatch = $CheckContent | Select-String -Pattern $script:webRegularExpression.mimeType

    return $mimeTypeMatch.matches.groups.value
}

<#
.SYNOPSIS
    Returns the MimeType for the STIG rule.

.Parameter CheckContent
    An array of the raw string data taken from the STIG setting.
#>
function Get-MimeType
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Extension
    )

    switch ( $Extension )
    {
        { $PsItem -match '\.exe|\.com' }
        {
            $mimeType = 'application/octet-stream'
        }
        { $PsItem -match '\.dll' }
        {
            $mimeType = 'application/x-msdownload'
        }
        { $PsItem -match '\.bat' }
        {
            $mimeType = 'application/x-bat'
        }
        { $PsItem -match '\.csh' }
        {
            $mimeType = 'application/x-csh'
        }
    }

    if ($null -ne $mimeType)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found MimeType: {0}" -f $mimeType)

        return $mimeType
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] No MimeType found"
        return $null
    }
}

<#
.SYNOPSIS
    Returns the Extension for the STIG rule.

.Parameter CheckContent
    An array of the raw string data taken from the STIG setting.
#>
function Get-Ensure
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    if ($CheckContent -match $script:webRegularExpression.mimeTypeAbsent)
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Ensure Absent"

        return "Absent"
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Ensure not found"
        return $null
    }
}

<#
.SYNOPSIS
    Tests to see if the stig rule needs to be split into multiples.

.Parameter CheckContent
    An array of the raw string data taken from the STIG setting.
#>
function Test-MultipleMimeTypeRule
{
    [CmdletBinding()]
    [OutputType( [bool] )]
    Param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $mimeTypes = $CheckContent | Where-Object -FilterScript {$_.startswith('.')}

    if ($mimeTypes.Count -gt 1)
    {
        Write-Verbose -message "[$($MyInvocation.MyCommand.Name)] : $true"
        return $true
    }
    else
    {
        Write-Verbose -message "[$($MyInvocation.MyCommand.Name)] : $false"
        return $false
    }
}

<#
.SYNOPSIS
    Splits a STIG setting into multiple rules when necessary.

.Parameter CheckContent
    An array of the raw string data taken from the STIG setting.
#>
function Split-MultipleMimeTypeRule
{
    [CmdletBinding()]
    [OutputType([object[]])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $splitMimeTypeRules = @()

    $mimeTypeMatches = $CheckContent | Select-String -Pattern $script:webRegularExpression.mimeType

    $mimeTypes  = $mimeTypeMatches.matches.groups.value

    $baseCheckContent = $CheckContent| Where-Object -Filterscript {$_ -notin $mimeTypes}

    foreach($mimeType in $mimeTypes)
    {
        $rule = $baseCheckContent + $mimeType
        $splitMimeTypeRules += ($rule -join "`r`n")
    }

    return $splitMimeTypeRules
}
#endregion
