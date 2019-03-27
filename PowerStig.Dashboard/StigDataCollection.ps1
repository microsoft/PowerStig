<#
    .SYNOPSIS
        Returns a list of registry rule found in Processed STIGs

    .PARAMETER RegistryHive
        Use this to define which Registry Hive key paths to return

    .PARAMETER LatestOnly
        Switch to return only paths found in latest STIG versions
#>
function Get-StigRegistryPathList
{
    Param
    (
        [Parameter()]
        [ValidateSet('HKEY_LOCAL_MACHINE', 'HKEY_CURRENT_USER')]
        [AllowNull()]
        [string]
        $RegistryHive,

        [Parameter()]
        [switch]
        $LatestOnly
    )

    if ($LatestOnly)
    {
        $registryRules = Get-RuleOfType -RuleType 'RegistryRule' -LatestOnly
    }
    else
    {
        $registryRules = Get-RuleOfType -RuleType 'RegistryRule'
    }

    if ($null -ne $RegistryHive)
    {
        $paths = $registryRules.RegistryRule.Key  | Where-Object -FilterScript {$_ -match "^$RegistryHive"}
    }
    else
    {
        $paths = $registryRules.RegistryRule.Key | 
            Where-Object -FilterScript {$_ -match "^HKEY_LOCAL_MACHINE" -or $_ -match "^HKEY_CURRENT_USER"} 
    }

    $paths = $paths | Select-Object -Unique
    return $paths
}

<#
    .SYNOPSIS
        Returns an obejct of rules specified by 'RuleType' found in Processed STIGs

    .PARAMETER RuleType
        A single or multiple STIG Rule types to retrieve

    .PARAMETER LatestOnly
        Switch to return only paths found in latest STIG versions
#>
function Get-RuleOfType
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('AccountPolicyRule','All','AuditPolicyRule','DnsServerSettingRule','FileContentRule','IisLoggingRule','GroupRule','MimeTypeRule','PermissionRule','ProcessMitigationRule','RegistryRule','SecurityOptionRule','ServiceRule','SqlScriptQueryRule','SslSettingsRule','UserRightRule','WebAppPoolRule','WebConfigurationPropertyRule','WindowsFeatureRule','WinEventLogRule','WmiRule','ManualRule','DocumentRule')]
        [string[]]
        $RuleType,

        [Parameter()]
        [switch]
        $LatestOnly
    )

    if ($LatestOnly)
    {
        $stigs = Get-StigOfType -RuleType $RuleType -LatestOnly
    }
    else
    {
        $stigs = Get-StigOfType -RuleType $RuleType
    }

    foreach ($stig in $stigs)
    {
        [xml] $content = Get-Content -Path $stig
        if ($RuleType -eq 'All')
        {
            $members = $content.DISASTIG | Get-Member | Where-Object -FilterScript {$_.MemberType -eq 'Property'}
            $typesToReturn = $members.Name | Where-Object -FilterScript {$_ -match '.*Rule'}
        }
        else 
        {
            $typesToReturn = $RuleType
        }

        foreach ($type in $typesToReturn)
        {
            $rules = $content.DISASTIG.$type.Rule
            foreach ($rule in $rules)
            {
                $rule | Add-Member -NotePropertyName 'StigName' -NotePropertyValue $stig.Name
                $rule | Add-Member -NotePropertyName 'RuleType' -NotePropertyValue $type
                $rule
            }
        }
    }
}

<#
    .SYNOPSIS
        Returns a list of STIGs containing specified rule types

    .PARAMETER RuleType
        Rule type to check for in processed STIGs

    .PARAMETER LatestOnly
        Switch to return only the latest  STIG versions
#>
function Get-StigOfType
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $RuleType,

        [Parameter()]
        [switch]
        $LatestOnly
    )

    if ($LatestOnly)
    {
        $stigList = Get-LatestStigList
    }
    else
    {
        $stiglist = (Get-ChildItem C:\Source\Repos\PowerStig\StigData\Processed -Exclude "*.org.default*", ".md").FullName
    }

    if ($RuleType -eq 'All')
    {
        return $stigList
    }

    $return = @()
    foreach ($type in $RuleType)
    {
        foreach ($stig in $stiglist)
        {
            [xml] $content = Get-Content $stig

            if ($content.DISASTIG.$type)
            {
                $return += $stig
            }
        }
    }

    return ($return | Select-Object -Unique)
}

<#
    .SYNOPSIS
        Returns a list of the Latest Stig Versions
#>
function Get-LatestStigList
{
    param()
    
    $stigList = Get-ChildItem C:\Source\Repos\PowerStig\StigData\Processed -Exclude "*.org.default*", "*.md"

    $stigGroups += $stigList | Group-Object -Property {$_.Name.Split('-')[0..($_.Name.split('-').count - 2)] -join '-'}
    $stigGroupsSorted = $stigGroups | Sort-Object {$_.Values}

    $stigGroupsSortedLatest = $stigGroupsSorted | ForEach-Object { $_.Group[-1] }

    return $stigGroupsSortedLatest
}

function Get-StigCheckBoxCollection
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $StigList
    )

    $return = @{
        1 = @()
        2 = @()
        3 = @()
        4 = @()
    }

    $counter = 1
    foreach ($stig in $StigList)
    {
        $return.$counter += $stig

        if ($counter -eq 4)
        {
            $counter = 1
        }
        else
        {
            $counter++
        }
    }
    
    return $return
}

<#
function Confirm-RegistryKeyPath
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $KeyPath,

        [Parameter()]
        [string[]]
        $GoodPaths
    )

    $pathArray = $KeyPath -split '\'

    
}

$time = measure-command {
    $test = Get-StigRegistryPathList -LatestOnly
}
#>
#$time = Measure-Command {
#$total = Get-RuleOfType -RuleType 'All' -LatestOnly #@('AccountPolicyRule','AuditPolicyRule','DocumentRule','DnsServerSettingRule','FileContentRule','IisLoggingRule','GroupRule','ManualRule','MimeTypeRule','PermissionRule','ProcessMitigationRule','RegistryRule','SecurityOptionRule','ServiceRule','SqlScriptQueryRule','SslSettingsRule','UserRightRule','WebAppPoolRule','WebConfigurationPropertyRule','WindowsFeatureRule','WinEventLogRule','WmiRule') -LatestOnly
#}
#$non = Get-RuleOfType -RuleType @('manualRule', 'DocumentRule') -LatestOnly

#$registry = Get-RuleOfType -RuleType @('registryrule') -LatestOnly


#$man = $total | Where {$_.ruletype -eq 'ManualRule'}
#
#$doc = $total | Where {$_.ruletype -eq 'Documentrule'}
#$docCat1 = $doc | where {$_.Severity -eq "High"}
#
#$manCat1 = $man | where {$_.Severity -eq "High"}
#$dup = @()
#foreach ($rule in $total)
#{
    #if ($rule.DuplicateOf)
    #{
        #$dup += $rule
    #}
#}