# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
# Header

#region Get-DomainName

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
        $domainName,

        [Parameter(Mandatory = $true, ParameterSetName = 'ForestName')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $forestName,

        [Parameter(ParameterSetName = 'DomainName')]
        [Parameter(ParameterSetName = 'ForestName')]
        [ValidateSet('FQDN', 'NetbiosName', 'DistinguishedName')]
        [string]
        $format = 'FQDN'
    )

    $fqdn = [string]::Empty

    if ($PSCmdlet.ParameterSetName -eq 'DomainName')
    {
        if ( [string]::IsNullOrEmpty( $domainName ) )
        {
            $fqdn = Get-DomainFQDN
        }
        else
        {
            $fqdn = $domainName
        }
    }
    else
    {
        if ( [string]::IsNullOrEmpty( $forestName ) )
        {
            $fqdn = Get-ForestFQDN
        }
        else
        {
            $fqdn = $forestName
        }
    }

    if ([string]::IsNullOrEmpty($fqdn))
    {
        Write-Warning "$($PSCmdlet.ParameterSetName) was not found."
    }

    switch ($format)
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
        [Parameter()]
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
        [Parameter()]
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
        [Parameter(Mandatory = $true)]
        [string]
        $FQDN
    )

    return $FQDN.Split('{.}')
}
#endregion

#region Get-OrgSettingsObject

<#
.SYNOPSIS
    Creates an OrganizationSetting object

.PARAMETER OrgSettings
    OrgSettings can be either a string path to an OrganizationalFile XML or a hash table of org settings
    to override from the default organization file.

.RETURN
    OrganizationalSetting

.EXAMPLE
    Get-OrgSettingsObject -OrgSettings @{"v-1000"="15"}
#>
Function Get-OrgSettingsObject
{
    [CmdletBinding()]
    [OutputType([OrganizationalSetting])]
    param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $orgSettings
    )

    switch ($orgSettings.GetType())
    {
        "string"
        {
            if (Test-Path -Path $orgSettings)
            {
                [xml] $orgSettingsXml = Get-Content -Path $orgSettings
                $orgSettingsObject = [OrganizationalSetting]::ConvertFrom($orgSettingsXml)
            }
            else
            {
                Throw "Organizational file not found"
            }
        }
        "xml"
        {
            $orgSettingsObject = [OrganizationalSetting]::ConvertFrom($orgSettings)
        }
        "hashtable"
        {
            $orgSettingsObject = [OrganizationalSetting]::ConvertFrom($orgSettings)
        }
    }

    return $orgSettingsObject
}


#endregion

#region Get-StigList

<#
    .SYNOPSIS
        Returns an array of all available STIGs with the associated Technology, TechnologyVersion, TechnologyRole, and StigVersion.
        This function is a wrapper of the StigData class, and the return of this function call will provide you with the values needed
        to create a default StigData object.

    .EXAMPLE
        Get-StigList
#>
Function Get-StigList
{
    [CmdletBinding()]
    [OutputType([PSObject[]])]
    param ()

    return [StigData]::GetAvailableStigs()
}

#endregion
