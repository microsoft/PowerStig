# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Returns the key and value properties for the STIG rule.

    .Parameter CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-SslValue
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
            $value = 'SslRequireCert'
        }
        { $checkContent -match 'If the "Require SSL"' }
        {
            $value = 'Ssl'
        }
        { ($checkContent -match 'Client Certificates Required') -and ($checkcontent -match 'set to "ssl128"') -and ($checkcontent -match 'If the "Require SSL"') }
        {
            $value = 'Ssl,SslNegotiateCert,SslRequireCert,Ssl128'
        }
    }

    if ($null -ne $value)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found value: {0}"  -f $value)

        return @{
            value = $value
        }
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] No Key or Value found"
        return $null
    }
}
