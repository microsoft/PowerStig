# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

$script:databasearray = @()

<#
    .SYNOPSIS
        Retrieves the SqlDatabase name from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-DatabaseName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkcontent)
    {
        {$PSItem -Match "((?i)Pubs)"}
        {
            if ($databasearray.Contains('Pubs') -eq $false)
            {
                $name = 'Pubs'
                $script:databasearray += $name
                break
            }
        }
        {$PSItem -Match "((?i)Northwind)"}
        {
            if ($databasearray.Contains('Northwind') -eq $false)
            {
                $name = 'Northwind'
                $script:databasearray += $name
                break
            }
        }
        {$PSItem -Match "((?i)AdventureWorks)"}
        {
            if ($databasearray.Contains('AdventureWorks') -eq $false)
            {
                $name = 'AdventureWorks'
                $script:databasearray += $name
                break
            }
        }
        {$PSItem -Match "((?i)WorldwideImporters)"}
        {
            if ($databasearray.Contains('WorldwideImporters') -eq $false)
            {
                $name = 'WorldwideImporters'
                $script:databasearray += $name
                break
            }
        }
    }

    return $name
}

<#
    .SYNOPSIS
        Sets the SqlDatabase ensure status rules from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Set-Ensure
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match 'If this system is identified as production' -or $PSItem -Match 'the existance of the publicly available'}
        {
            $ensure = 'Absent'
        }
    }

    return $ensure
}

<#
    .SYNOPSIS
        Check if the string (MitigationTarget) contains a comma. If so the rule needs to be split
#>

function Test-MultipleSqlDatabase
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $matchDatabase = ($CheckContent | Select-String -Pattern "(Pubs|Northwind|AdventureWorks|WorldwideImporters)" -AllMatches).Matches.Value

    if ($matchDatabase -gt 1)
    {
        return $true
    }

    return $false
}

function Split-MultipleSqlDatabase
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $result = @()
    $matchDatabase = ($CheckContent | Select-String -Pattern "(Pubs|Northwind|AdventureWorks|WorldwideImporters)" -AllMatches).Matches.Value

    foreach ($database in $matchDatabase)
    {
        $result += $CheckContent
    }

    return $result
}
