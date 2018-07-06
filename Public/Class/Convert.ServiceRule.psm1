#region Header V1
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\Common.Enum.psm1
using module .\Convert.Stig.psm1
using module .\..\Data\Convert.Data.psm1
# Additional required modules

#endregion
#region Data Section
data ServicesDisplayNameToName
{
    ConvertFrom-StringData -stringdata @'
        Active Directory Domain Services = NTDS
        DFS Replication = DFSR
        DNS Client = Dnscache
        DNS Server = DNS
        Group Policy Client = gpsvc
        Intersite Messaging = IsmServ
        Kerberos Key Distribution Center = Kdc
        Windows Time = W32Time
'@
}
#endregion
#region Class Definition
Class ServiceRule : STIG
{
    [string] $ServiceName
    [string] $ServiceState
    [string] $StartupType
    [ensure] $Ensure

    # Constructor
    ServiceRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetServiceName ()
    {
        $thisServiceName = Get-ServiceName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisServiceName ) )
        {
            $this.set_ServiceName( $thisServiceName )
            $this.set_Ensure( [ensure]::Present )
        }

    }

    [void] SetServiceState ()
    {
        $thisServiceState = Get-ServiceState -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisServiceState ) )
        {
            $this.set_ServiceState( $thisServiceState )
        }
    }

    [void] SetStartupType ()
    {
        $thisServiceStartupType = Get-ServiceStartupType -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisServiceStartupType ) )
        {
            $this.set_StartupType( $thisServiceStartupType )
        }
    }

    static [bool] HasMultipleRules ( [string] $Servicename )
    {
        return ( Test-MultipleServiceRule -ServiceName $Servicename )
    }

    static [string[]] SplitMultipleRules ( [string] $ServiceName )
    {
        return ( Split-MultipleServiceRule -ServiceName $Servicename )
    }
}
#endregion
#region Method Functions
<#
    .SYNOPSIS
        Parses Check-Content element to retrieve the Service Name.
#>
function Get-ServiceName
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [parameter( Mandatory = $true )]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    if ( $CheckContent -match $Script:RegularExpression.McAfee )
    {
        $serviceName = 'McAfee'
    }
    elseif ( $CheckContent -match $Script:RegularExpression.SmartCardRemovalPolicy )
    {
        $serviceName = 'SCPolicySvc'
    }
    elseif ( $CheckContent -match $Script:RegularExpression.SecondaryLogon )
    {
        $serviceName = 'seclogon'
    }
    elseif ( $CheckContent -match $Script:RegularExpression.followingservices )
    {
        $regexMatch = $CheckContent | Select-String $Script:RegularExpression.dash
        $svcArray = @()
        foreach ($match in $regexMatch)
        {
            $svc = $match -replace $Script:RegularExpression.dash, ''
            if ( $svc.Contains('(') )
            {
                $svc = $svc.ToString().Substring(0, $svc.IndexOf('(') - 1)
            }
            if ( $Script:ServicesDisplayNameToName.Contains( $svc.Trim() ) )
            {
                $svc = $Script:ServicesDisplayNameToName.$( $svc.Trim() )
            }
            $svcArray += $svc.Trim()
        }
        $serviceName = $svcArray -join ','
    }
    else
    {
        $regexMatch = $CheckContent | Select-String $Script:RegularExpression.textBetweenParentheses

        if ( -not [string]::IsNullOrEmpty( $regexMatch ) )
        {
            $serviceName = $regexMatch.matches.groups[-1].Value
        }
    }
    # There is an edge case with the rule concerning the FTP Service. All service rules have the service names inside of parentheses (ex. (servicename)), however
    # the rule pertaining to the FTP service presents this scenario: (Service name: FTPSVC)
    if ( $serviceName -match 'Service name: FTPSVC' )
    {
        $serviceName = ( $serviceName -split ':' )[-1]
    }

    if ( -not [string]::IsNullOrEmpty( $serviceName ) )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]  Found service name   : $serviceName"

        $serviceName = $serviceName.Trim()

        Write-Verbose "[$($MyInvocation.MyCommand.Name)]  Trimmed service name : $serviceName"
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]  Found service name   : $false"
        return
    }

    if ( $Script:ServicesDisplayNameToName.Contains( $serviceName ) )
    {
        $serviceName = $Script:ServicesDisplayNameToName.$serviceName
    }

    return $serviceName
}

<#
    .SYNOPSIS
        Parses Check-Content element to retrieve the Service State.
#>
function Get-ServiceState
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [parameter( Mandatory = $true )]
        [psobject]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $serviceName = Get-ServiceName -CheckContent $CheckContent

    # ServiceState McAfee and Smartcard is running everything else is stopped
    if ( $serviceName -match 'McAfee' -or $serviceName -eq 'SCPolicySvc' )
    {
        return 'Running'
    }
    elseif ( $CheckContent -match 'is installed and not disabled, this is a finding' )
    {
        return 'Stopped'
    }
    elseif ( $CheckContent -match 'is not set to Automatic, this is a finding' -or
             $CheckContent -match 'is not Automatic, this is a finding' )
    {
        return 'Running'
    }
    else
    {
        return 'Stopped'
    }
}

<#
    .SYNOPSIS
        Parses Check-Content element to retrieve the Service Startup Type.
#>
function Get-ServiceStartupType
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [parameter( Mandatory = $true )]
        [psobject]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $serviceName = Get-ServiceName -CheckContent $CheckContent

    # StartupType McAfee and Smartcard is Automatic everything else is disabled
    if ( $serviceName -match 'McAfee' -or $serviceName -eq 'SCPolicySvc' )
    {
        return 'Automatic'
    }
    elseif ( $CheckContent -match 'is installed and not disabled, this is a finding' )
    {
        return 'Disabled'
    }
    elseif ( $CheckContent -match 'is not set to Automatic, this is a finding' -or
        $CheckContent -match 'is not Automatic, this is a finding' )
    {
        return 'Automatic'
    }
    else
    {
        return 'Disabled'
    }
}
<#
    .SYNOPSIS
        Check if the string (ServiceName) contains a comma. This was added to enable testing of
        the methods used to determine how the test is accomplished.
#>
function Test-MultipleServiceRule
{
    [CmdletBinding()]
    [OutputType([bool])]
    Param
    (
        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $ServiceName
    )

    if ( $ServiceName -match ',')
    {
        return $true
    }
    return $false
}
<#
    .SYNOPSIS
        Check if the string (ServiceName) contains Multiple Service names then Splits them. This was added to enable testing of
        the methods used to determine how the test is accomplished.
#>
function Split-MultipleServiceRule
{
    [CmdletBinding()]
    [OutputType([array])]
    Param
    (
        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $ServiceName
    )

    return ( $ServiceName -split ',' )
}

#endregion
