# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type UserRightRule

$domainGroupTranslation = @{
    'Administrators'            = 'Builtin\Administrators'
    'Auditors'                  = '{0}\auditors'
    'Authenticated Users'       = 'Authenticated Users'
    'Domain Admins'             = '{0}\Domain Admins'
    'Guests'                    = 'Guests'
    'Local Service'             = 'NT Authority\Local Service'
    'Network Service'           = 'NT Authority\Network Service'
    'NT Service\WdiServiceHost' = 'NT Service\WdiServiceHost'
    'NULL'                      = ''
    'Security'                  = '{0}\security'
    'Service'                   = 'Service'
    'Window Manager\Window Manager Group' = 'Window Manager\Window Manager Group'
}

$forestGroupTranslation = @{
    'Enterprise Admins'         = '{0}\Enterprise Admins'
    'Schema Admins'             = '{0}\Schema Admins'
}

if ($DomainName -and $ForestName)
{
    # This requires a local forest and/or domain name to be injected to ensure a valid account name.
    $DomainName = PowerStig\Get-DomainName -DomainName $DomainName -Format NetbiosName
    $ForestName = PowerStig\Get-DomainName -ForestName $ForestName -Format NetbiosName
}

foreach ($rule in $rules)
{
    Write-Verbose -Message $rule

    if ($rule.Identity -eq 'NULL')
    {
        $identityList = $null
    }
    else
    {
        $identitySplit = $rule.Identity -split ","
        [System.Collections.ArrayList] $identityList = @()

        foreach ($identity in $identitySplit)
        {
            if (-not ([string]::IsNullorWhitespace($domainName)) -and $domainGroupTranslation.Contains($identity))
            {
                [void] $identityList.Add($domainGroupTranslation.$identity -f $DomainName )
            }
            elseif (-not ([string]::IsNullorWhitespace($forestName)) -and $forestGroupTranslation.Contains($identity))
            {
                [void] $identityList.Add($forestGroupTranslation.$identity -f $ForestName )
            }
            # Default to adding the identify as provided for any non-default identities.
            else
            {
                if ($identity -notmatch "Schema Admins|Enterprise Admins|security|Domain Admins|auditors")
                {
                    [void] $identityList.Add($identity)
                }
            }
        }
    }

    $ruleForce = $null
    [void][bool]::TryParse($rule.Force, [ref] $ruleForce)

    UserRightsAssignment (Get-ResourceTitle -Rule $rule)
    {
        Policy   = ($rule.DisplayName -replace " ", "_")
        Identity = $identityList
        Force    = $ruleForce
    }
}
