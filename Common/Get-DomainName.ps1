# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Main Functions
<#
    .SYNOPSIS
        Enforces the behavior of getting the domain name.
        If a domain name is provided, it will be used.
        If a domain name is not provided, the domain name of the generating system will be used.

    .PARAMETER DomainName
        The FQDN of the domain the configuration will be running on.

    .PARAMETER ForestName
        The FQDN of the forest the configuration will be running on.

    .PARAMETER Format
        Determines the format in which to convert the FQDN provided into and return back

    .OUTPUTS
        string

    .EXAMPLE
        Get-DomainName -DomainName "contoso.com" -Format FQDN

        Returns "contoso.com"

    .EXAMPLE
        Get-DomainName -DomainName "contoso.com" -Format NetbiosName

        Returns "contoso"

    .EXAMPLE
        Get-DomainName -ForestName "contoso.com" -Format DistinguishedName

        Returns "DC=contoso,DC=com"
#>
Function Get-DomainName 
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'DomainName')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $DomainName,

        [Parameter(Mandatory = $true, ParameterSetName = 'ForestName')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $ForestName,

        [Parameter(ParameterSetName = 'DomainName')]
        [Parameter(ParameterSetName = 'ForestName')]
        [ValidateSet('FQDN', 'NetbiosName', 'DistinguishedName')]
        [string]
        $Format = 'FQDN'
    )

    $fqdn = [string]::Empty

    if ($PSCmdlet.ParameterSetName -eq 'DomainName')
    {
        if ( [string]::IsNullOrEmpty( $DomainName ) ) 
        {
            $fqdn = Get-DomainFQDN
        }
        else 
        {
            $fqdn = $DomainName
        }
    }
    else
    {
        if ( [string]::IsNullOrEmpty( $ForestName ) )
        {
            $fqdn = Get-ForestFQDN
        }
        else
        {
            $fqdn = $ForestName
        }
    }

    if ([string]::IsNullOrEmpty($fqdn))
    {
        Write-Warning "$($PSCmdlet.ParameterSetName) was not found."
    }

    switch ($Format) 
    {
        'FQDN' 
        {
            return $fqdn
        }
        'NetbiosName'
        {
            return Get-NetbiosName -FQDN $fqdn
        }
        'DistinguishedName'
        {
            return Get-DistinguishedName -FQDN $fqdn
        }
    }
}

#endregion Main Functions
#region Support Functions

<#
 .SYNOPSIS
  returns $env:USERDNSDOMAIN to support mocking in unit tests
#>
Function Get-DomainFQDN
{
    [CmdletBinding()]
    [OutputType([string])]
    param 
    ( )

    return $env:USERDNSDOMAIN
}

<#
 .SYNOPSIS
  Calls ADSI to discover the forest root (DN) and converts it to an FQDN.
#>
Function Get-ForestFQDN
{
    [CmdletBinding()]
    [OutputType([string])]
    param 
    ( )

    $forestRoot = [ADSI]"LDAP://RootDSE"
    return $forestRoot.rootDomainNamingContext -replace '^DC=', '' -replace '.DC=', '.'
}

Function Get-NetbiosName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $FQDN
    )

    $parts = Get-DomainParts -FQDN $FQDN
    If ($parts.Count -gt 1)
    {
        return $parts[0]
    }
    else 
    {
        return $parts
    }
}

Function Get-DistinguishedName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [parameter()]
        [string]
        $FQDN
    )

    $parts = Get-DomainParts -FQDN $FQDN
    return Format-DistinguishedName -Parts $parts
}

Function Format-DistinguishedName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [parameter()]
        [string[]]
        $Parts
    )

    $distinguishedName = ""
    $lastIndex = $Parts.Count - 1

    foreach ($part in $Parts)
    {
        if ($part -eq $Parts[$lastIndex])
        {
            $distinguishedName += 'DC=' + $part.ToString()
        }
        else
        {
            $distinguishedName += 'DC=' + $part.ToString() + ','
        }
    }

    return $distinguishedName.ToString()
}

Function Get-DomainParts
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $FQDN
    )

    return $FQDN.Split('{.}')
}
#endregion Support Functions
