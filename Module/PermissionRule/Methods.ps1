# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Parses the rawString from the rule to retrieve the PermissionTargetPath
#>
function Get-PermissionTargetPath
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $StigString
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    switch ($StigString)
    {
        # Do not use $env: for environment variables. They will not be able to be converted to text for XML.
        # get path for permissions that pertains to event logs
        { $stigString -match $script:permissionRegEx.WinEvtDirectory }
        {
            $parentheseMatch = $StigString | Select-String -Pattern $script:eventLogRegularExpression.name

            if ( $StigString -match $script:permissionRegEx.dnsServerLog )
            {
                $childPath = 'DNS Server.evtx'
            }
            else
            {
                $childPath = $parentheseMatch.Matches.Groups[-1].Value.trim()
            }

            $permissionTargetPath = '%windir%\SYSTEM32\WINEVT\LOGS\' + $childPath
            break
        }

        # get path for permissions that pertains to eventvwr.exe
        { $StigString -match $script:permissionRegEx.eventViewer }
        {
            $permissionTargetPath = '%windir%\SYSTEM32\eventvwr.exe'
            break
        }

        # get path that pertains to C:\

        { $StigString -match $script:permissionRegEx.cDrive }
        {
            $permissionTargetPath = '%SystemDrive%\'
            break
        }

        # get path that pertains to Sysvol
        { $StigString -match $script:permissionRegEx.SysVol}
        {
            $permissionTargetPath = '%windir%\sysvol'
            break
        }

        # get path that pertains to  C:\Windows
        { $StigString -match $script:permissionRegEx.systemRoot }
        {
            $permissionTargetPath = '%windir%'
            break
        }

        # get path that pertains to registry Installed Components key
        { $StigString -match $script:permissionRegEx.permissionRegistryInstalled }
        {
            $permissionTargetPath = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Installed Components\'
            break
        }

        # get path that pertains to registry Winlogon key
        { $StigString -match $script:permissionRegEx.permissionRegistryWinlogon }
        {
            $permissionTargetPath = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Winlogon\'
            break
        }

        # get path that pertains to registry WinReg key
        { $StigString -match $script:permissionRegEx.permissionRegistryWinreg }
        {
            $permissionTargetPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\'
            break
        }

        # get path that pertains to registry NTDS key
        { $StigString -match $script:permissionRegEx.permissionRegistryNTDS }
        {
            $permissionTargetPath = '%windir%\NTDS\*.*'
            break
        }

        # get path that pertains to both program files directories
        { $StigString -match $script:permissionRegEx.programFiles }
        {
            $permissionTargetPath = '%ProgramFiles%;%ProgramFiles(x86)%'
            break
        }

        # get crypto folder path
        { $StigString -match $script:permissionRegEx.cryptoFolder }
        {
            $permissionTargetPath = '%ALLUSERSPROFILE%\Microsoft\Crypto\Keys'
            break
        }

        # get path that pertains to Admin Shares
        { $StigString -match $Script:permissionRegEx.adminShares }
        {
            $permissionTargetPath = $null
            break
        }

        # get Active Directory Path
        { $stigString -match $script:permissionRegEx.ADAuditPath }
        {
            $ADPath = (Select-String -InputObject $stigString -Pattern $script:permissionRegEx.ADAuditPath) -replace $script:permissionRegEx.ADAuditPath, "" -replace " object.*", ""
            $permissionTargetPath = $script:ADAuditPath.$($ADPath.Trim())
            break
        }

        # get HKLM\Security path
        {
            $StigString -match $script:permissionRegEx.hklmSecurity -and
            $StigString -match $script:permissionRegEx.hklmSoftware -and
            $StigString -match $script:permissionRegEx.hklmSystem
        }
        {
            $permissionTargetPath = 'HKLM:\SECURITY;HKLM:\SOFTWARE;HKLM:\SYSTEM'
            break
        }

        # get the individual HKLM paths
        { $StigString -match $script:permissionRegEx.hklmSecurity }
        {
            $permissionTargetPath = 'HKLM:\SECURITY'
        }

        { $StigString -match $script:permissionRegEx.hklmSoftware }
        {
            $permissionTargetPath = 'HKLM:\SOFTWARE'
        }

        { $StigString -match $script:permissionRegEx.hklmSystem }
        {
            $permissionTargetPath = 'HKLM:\SYSTEM'
        }

        # get path for C:, Program file, and Windows
        {
            $StigString -match $script:permissionRegEx.rootOfC -and
            $StigString -match $script:permissionRegEx.winDir -and
            $StigString -match $script:permissionRegEx.programFiles
        }
        {
            $permissionTargetPath = '%SystemDrive%;%ProgramFiles%;%Windir%'
            break
        }
        {
            $StigString -match $script:permissionRegEx.rootOfC -and
            $StigString -notmatch $script:permissionRegEx.winDir -and
            $StigString -notmatch $script:permissionRegEx.programFileFolder
        }
        {
            $permissionTargetPath = '%SystemDrive%'
            break
        }
        { $stigString -match $script:permissionRegEx.winDir }
        {
            $permissionTargetPath = '%Windir%'
            break
        }
        {  $stigString -match $script:permissionRegEx.programFileFolder }
        {
            $permissionTargetPath = '%ProgramFiles%'
            break
        }
        { $stigString -match $script:permissionRegEx.programFiles86 }
        {
            $permissionTargetPath = '%ProgramFiles(x86)%'
            break
        }
        { $stigString -match $script:permissionRegEx.inetpub }
        {
            $permissionTargetPath = '%windir%\inetpub'
            break
        }

        default
        {
            break
        }
    }

    return $permissionTargetPath
}

<#
    .SYNOPSIS
        This function calls ConvertTo-AccessControlEntry but allows to get AccessControlEntry objects,
        however this allows us to handle edge cases in the rawString from the xccdf.
#>
function Get-PermissionAccessControlEntry
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $StigString
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    switch ($StigString)
    {
        { $StigString -match $script:permissionRegEx.permissionRegistryWinlogon }
        {
            <#
                Permission rule that pertains to HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\
                This rule has an edge case which specifies the same inheritance to all the principals
                and is not in the same format as the other rules.
            #>
            return ConvertTo-AccessControlEntry -StigString $StigString -inheritanceInput 'This key and subkeys'
        }

        { $StigString -match $script:permissionRegEx.InheritancePermissionMap }
        {
            return ConvertTo-AccessControlEntryIF -StigString $StigString
        }

        { $StigString -join " " -match $script:permissionRegEx.TypePrincipalAccess }
        {
            return ConvertTo-AccessControlEntryGrouped -StigString $StigString
        }

        { $StigString -match $script:permissionRegEx.cryptoFolder }
        {
            $cryptoFolderStigString = "SYSTEM, Administrators - Full Control - This folder, subfolders and files"
            return ConvertTo-AccessControlEntry -StigString $cryptoFolderStigString
        }

        { $StigString -match $script:permissionRegEx.inetpub }
        {
            # In IIS Server Stig rule V-76745 says creator/owner should have special permissions to subkeys so we ignore it. All rules that are properly documented are converted
            $inetpubFolderStigString = @()
            foreach ($line in $stigString)
            {
                if ($line -notMatch "Creator/Owner" -and $line -match ":")
                {
                    $inetpubFolderStigString += ($line -replace ': ', ' - ') -replace '\(built-in security group\)'
                }
            }

            return ConvertTo-AccessControlEntry -StigString $inetpubFolderStigString
        }

        default
        {
            return ConvertTo-AccessControlEntry -StigString $StigString
        }
    }
}

<#
    .SYNOPSIS
        This function converts the raw text from the STIG rule to a hashtable with
        the following keys: Principal,FileSystemRights, and Inheritance. This is to
        handle scenarios where a target has multiple principals assigned permissions
        to it.
#>
function ConvertTo-AccessControlEntryGrouped
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $StigString
    )

    $accessControlEntryPrincipal = $StigString | Select-String -Pattern "Principal\s*-"
    $accessControlEntryType      = $StigString | Select-String -Pattern "Type\s*-"
    $accessControlEntryAccess    = $StigString | Select-String -Pattern "Access\s*-"
    $accessControlEntryApplies   = $StigString | Select-String -Pattern "Applies To\s*-"
    $accessControlEntrySpecial   = $StigString | Select-String -Pattern "\(Access - Special\s*"

    foreach ($entry in $accessControlEntryType)
    {
        $type = ($entry.ToString() -Split "-")[1].Trim()

        $principalObject = $accessControlEntryPrincipal |
            Where-Object {$PSItem.LineNumber -gt $entry.LineNumber} |
                Sort-Object -Property LineNumber |Select-Object -First 1

        $principal = ($principalObject.ToString() -split '-')[1].Trim()

        $rightsObject = $accessControlEntryAccess |
            Where-Object {$PSItem.LineNumber -gt $entry.LineNumber} |
                Sort-Object -Property LineNumber | Select-Object -First 1

        $rights = ($RightsObject.ToString() -split "-")[1].Trim()

        $inheritanceObject = $accessControlEntryApplies |
            Where-Object {$PSItem.LineNumber -gt $RightsObject.LineNumber} |
                Sort-Object -Property LineNumber | Select-Object -First 1

        if ($inheritanceObject)
        {
            $inheritance = ($InheritanceObject.ToString() -split "-")[1].Trim()
        }
        else
        {
            $inheritance = ""
        }

        if ($rights -eq "Special")
        {
            $specialPermissions = $accessControlEntrySpecial |
                Where-Object {$PSItem.LineNumber -gt $rightsObject.LineNumber} |
                    Sort-Object -Property LineNumber | Select-Object -First 1

            if ($specialPermissions.ToString().Contains(':'))
            {
                $rights = ($specialPermissions -split ':')[1].Trim()
            }
            else
            {
                $rights = ($specialPermissions -split '=')[1].Trim()
            }

            $rights = $rights.Substring(0,$rights.Length -1)
        }

        $accessControlEntries += [pscustomobject[]]@{
            Principal          = $principal
            ForcePrincipal     = Get-ForcePrincipal -StigString $StigString
            Rights             = Convert-RightsConstant -RightsString $rights
            Inheritance        = $script:inheritanceConstant[[string]$inheritance.trim()]
            Type               = $type
        }
    }
    return $accessControlEntries
}

<#
    .SYNOPSIS
        Converts permission rules entries that have an inheritance mapping
#>
function ConvertTo-AccessControlEntryIF
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $StigString
    )

    $accessControlEntryMatches = $StigString | Select-String -Pattern $script:permissionRegEx.InheritancePermissionMap
    $permissions = $StigString | Select-String -Pattern $script:permissionRegEx.PermissionRuleMap

    foreach ($entry in $accessControlEntryMatches)
    {
        $entry = $entry -replace ':', ' - ' -replace '\)\s*\(', ') - ('
        foreach ($permission in $permissions)
        {
            $perm = $permission -split '-'
            $perm[0] = $perm[0] -replace '\(','\(' -replace '\)','\)'
            $entry = $entry -replace $perm[0].Trim(), $perm[1].Trim()
        }

        $principal, [string]$inheritance, $fileSystemRights = $entry -split $script:permissionRegEx.spaceDashSpace

        if (-not $script:inheritanceConstant[[string]$inheritance.trim()])
        {
            $inheritance = ""
        }
        else
        {
            $inheritance = $script:inheritanceConstant[[string]$inheritance.trim()]
        }

        $accessControlEntries += [pscustomobject[]]@{
            Principal      = $principal.trim()
            ForcePrincipal = Get-ForcePrincipal -StigString $StigString
            Rights         = Convert-RightsConstant -RightsString $fileSystemRights
            Inheritance    = $inheritance
        }
    }

    return $accessControlEntries
}

<#
    .SYNOPSIS
        Converts the raw text from the STIG rule hashtable with
        the following keys: Principal,FileSystemRights, and Inheritance.
#>
function ConvertTo-AccessControlEntry
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $StigString,

        [Parameter()]
        [string]
        $inheritanceInput
    )

    $accessControlEntryMatches = $StigString | Select-String -Pattern $script:permissionRegEx.spaceDashSpace

    foreach ( $entry in $accessControlEntryMatches )
    {
        if ( $entry -notmatch 'Type|Inherited|Columns|Principal|Applies' )
        {
            <#
                Access control entries are commonly formatted like so: 'Principal - FileSystemRights - Inheritance
                we will split on a regex pattern the represents space dash space ( - )
            #>
            $principals, $fileSystemRights, [string]$inheritance = $entry -split $script:permissionRegEx.spaceDashSpace

            if ( $fileSystemRights -match $Script:commonRegEx.textBetweenParentheses )
            {
                $inheritance = [regex]::Match( $fileSystemRights, $script:commonRegEx.textBetweenParentheses ).groups[1].Value

                $fileSystemRights = ($fileSystemRights -split '\(')[0]
            }

            # There is an edge case V-63593 which states the rights should be 'Special' but it doesn't state what the special rights should be so we ignore it.
            if ( $StigString -match $script.$script:permissionRegEx.hklmRootKeys -and $fileSystemRights.Trim() -eq 'Special')
            {
                break
            }
            <#
                There is an edge case in V-26070 where the inheritance is specified in the rule outside of the common format
                V-26070 states the inheritance is to be applied to all the prinicpals.  So if an inheritance is passed in from the Inheritance
                parameter we applied to all the prinicipals.  If not we parse the rawString to extract the inheritance.
            #>
            if ( $inheritanceInput )
            {
                $inheritance = $inheritanceInput
            }

            foreach ( $principal in $principals -split ',' )
            {
                $accessControlEntries += [pscustomobject[]]@{
                    Principal      = $principal.trim()
                    ForcePrincipal = Get-ForcePrincipal -StigString $StigString
                    Rights         = Convert-RightsConstant -RightsString $fileSystemRights
                    Inheritance    = $script:inheritanceConstant[[string]$inheritance.trim()]
                }
            }
        }
    }

    return $accessControlEntries
}

<#
    .SYNOPSIS
        Converts strings describing the fileRights permissions to constants that are usable.
        Additonally this addresses the edge case when the fileRights are seperated by a forward slash "/"
#>
function Convert-RightsConstant
{
    [CmdletBinding()]
    [OutputType([array])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $RightsString
    )

    foreach ( $string in $RightsString )
    {
        $values = @()
        $rights = $(
            if ( $string.Contains('/') )
            {
                $string.Split('/')
            }
            else
            {
                $string.Split(',')
            }
        )

        foreach ($right in $rights)
        {
            switch ($this.dscresource)
            {
                'ActiveDirectoryAuditRuleEntry'
                {
                    $values += $script:activeDirectoryRightsConstant[$right.trim()]
                }
                'RegistryAccessEntry'
                {
                    $values += $script:registryRightsConstant[$right.trim()]
                }
                'NTFSAccessEntry'
                {
                    $values += $script:fileRightsConstant[$right.trim()]
                }
                '(blank)'
                {
                    $values += $script:activeDirectoryRightsConstant[$right.trim()]
                }
            }
        }
    }

    return $values -join ','
}

<#
    .SYNOPSIS
        Checks if the permission rule target has multiple paths

    .PARAMETER PermissionPath
        Permission rule target path
#>
function Test-MultiplePermissionRule
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $PermissionPath
    )

    if ( $PermissionPath -match ';')
    {
        return $true
    }

    return $false
}

<#
    .SYNOPSIS
        Returns an array of permission rule target paths

    .PARAMETER PermissionPath
        Permission rule target path
#>
function Split-MultiplePermissionRule
{
    [CmdletBinding()]
    [OutputType([System.Array])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    $result = @()
    [System.Collections.ArrayList]$contentRanges = @()
    # test for multiple paths at HKLMRoot
    if ( $CheckContent -match $script:permissionRegEx.hklmRootKeys )
    {
        $hklmSecurityMatch = $CheckContent | Select-String -Pattern $script:permissionRegEx.hklmSecurity
        $hklmSoftwareMatch = $CheckContent | Select-String -Pattern $script:permissionRegEx.hklmSoftware
        $hklmSystemMatch   = $CheckContent | Select-String -Pattern $script:permissionRegEx.hklmSystem

        [void]$contentRanges.Add(($hklmSecurityMatch.LineNumber - 1)..($hklmSoftwareMatch.LineNumber - 2))
        [void]$contentRanges.Add(($hklmSoftwareMatch.LineNumber - 1)..($hklmSystemMatch.LineNumber - 2))
        [void]$contentRanges.Add(($hklmSystemMatch.LineNumber - 1)..($checkContent.Length - 4))

        $headerLineRange = 0..($hklmSecurityMatch.LineNumber - 2)
        $footerLineRange = ($CheckContent.Length - 4)..($CheckContent.Length + 1)
    }
    elseIf ( $CheckContent -match $script:permissionRegEx.rootOfC -and
        $CheckContent -match $script:permissionRegEx.programFiles -and
        $CheckContent -match $script:permissionRegEx.winDir
    )
    {
        $rootOfCMatch = $CheckContent | Select-String -Pattern $script:permissionRegEx.rootOfC | Select-Object -First 1
        $programFilesMatch = $CheckContent | Select-String -Pattern $script:permissionRegEx.programFileFolder
        $windowsDirectoryMatch = $CheckContent | Select-String -Pattern $script:permissionRegEx.winDir
        $icaclsMatch = $CheckContent | Select-String -Pattern 'Alternately\suse\sicacls'

        [void]$contentRanges.Add(($rootOfCMatch.LineNumber - 1)..($programFilesMatch.LineNumber - 2))
        [void]$contentRanges.Add(($programFilesMatch.LineNumber - 1)..($windowsDirectoryMatch.LineNumber - 2))
        [void]$contentRanges.Add(($windowsDirectoryMatch.LineNumber - 1)..($icaclsMatch.LineNumber - 2))

        $headerLineRange = 0..($rootOfCMatch.LineNumber - 2)
        $footerLineRange = ($icaclsMatch.LineNumber - 1)..($icaclsMatch.LineNumber - 1)
    }
    else
    {
        $programFileTargets = '^\\Program Files and ','and \\Program Files \(x86\)'
        foreach ($target in $programFileTargets)
        {
            $result += Join-CheckContent -Body ($CheckContent -replace $target)
        }

        return $result
    }

    foreach ( $range in $contentRanges )
    {
        $result += Join-CheckContent -Header $CheckContent[$headerLineRange] -Body $CheckContent[$range] -Footer $CheckContent[$footerLineRange]
    }

    return $result
}

<#
    .SYNOPSIS
        Retrieves the Force Principal attribute
#>
function Get-ForcePrincipal
{
    [CmdletBinding()]
    [OutputType( [boolean] )]
    param
    (
        [psobject] $StigString
    )

    # Setting default value for the time being. In the future additional logic could be added here in order to dynamically determine what this should be.
    return $false
}

<#
    .SYNOPSIS
        Converts a string array into a multi-line string object
#>
function Join-CheckContent
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [string[]]
        $Header,

        [Parameter()]
        [string[]]
        [AllowEmptyString()]
        $Body,

        [Parameter()]
        [string[]]
        [AllowEmptyString()]
        $Footer
    )

    $stringBuilder = [System.Text.StringBuilder]::new()

    foreach ( $line in $Header)
    {
        [void]$stringBuilder.AppendLine($line)
    }

    foreach ($line in $Body)
    {
        [void]$stringBuilder.AppendLine($line)
    }

    foreach ($line in $Footer)
    {
        [void]$stringBuilder.AppendLine($line)
    }

    return $stringBuilder.ToString()
}
#endregion
