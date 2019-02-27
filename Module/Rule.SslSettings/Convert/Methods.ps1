# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Returns the ConfigSection property for the STIG rule.

    .Parameter CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-ConfigSection
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $cleanCheckContent = $checkContent -replace [RegularExpression]::ExcludeExtendedAscii, '"'

    if ($cleanCheckContent -match 'SSL Settings')
    {
        $configSection = '/system.webServer/security/access'
    }

    if ($null -ne $configSection)
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Found ConfigSection: $($configSection)"
        return $configSection
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] ConfigSection not found"
        return $null
    }
}

<#
    .SYNOPSIS
        Returns the key and value properties for the STIG rule.

    .Parameter CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-KeyValuePair
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    switch ( $checkContent )
    {
        { $checkContent -match 'Verify the "Clients Certificate Required"' }
        {
            $key = 'sslflags'
            $value = 'SslRequireCert'
        }
        { $checkContent -match 'If the "Require SSL"' }
        {
            $key = 'sslflags'
            $value = 'Ssl'
        }
        { ($checkContent -match 'Client Certificates Required') -and ($checkcontent -match 'set to "ssl128"') -and ($checkcontent -match 'If the "Require SSL"') }
        {
            $key = 'sslflags'
            $value = 'Ssl,SslNegotiateCert,SslRequireCert,Ssl128'
        }
    }

    if ($null -ne $key)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found Key: {0}, value: {1}" -f $key, $value)

        return @{
            key   = $key
            value = $value
        }
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] No Key or Value found"
        return $null
    }
}
