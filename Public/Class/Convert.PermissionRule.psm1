#region Header V1
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\Common.Enum.psm1
using module .\Convert.Stig.psm1
using module .\..\Data\Convert.Data.psm1
# Additional required modules

#endregion
#region Class Definition
Class PermissionRule : STIG
{
    [string] $Path
    [object[]] $AccessControlEntry
    [bool] $Force

    PermissionRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass($StigRule)
    }

    # Methods

    [void] SetPath ( )
    {
        $thisPath = Get-PermissionTargetPath -StigString $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPath ) )
        {
            $this.set_Path($thisPath)
        }
    }

    [void] SetForce ()
    {
        # For now we're setting a default value. Later there could be additional logic here
        $this.set_Force($true)
    }

    [void] SetAccessControlEntry ( )
    {
        $thisAccessControlEntry = Get-PermissionAccessControlEntry -StigString $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisAccessControlEntry ) )
        {
            foreach( $Principal in $thisAccessControlEntry.Principal )
            {
                $this.SetStatus( $Principal )
            }

            foreach ( $Rights in $thisAccessControlEntry.Rights )
            {
                if ( $Rights -eq 'blank' )
                {
                    $this.SetStatus( "", $true )
                    continue
                }
                $this.SetStatus( $Rights )
            }

            $this.set_AccessControlEntry( $thisAccessControlEntry )
        }
    }

    static [bool] HasMultipleRules ( [string] $StigString )
    {
        $permissionPaths = Get-PermissionTargetPath -StigString ($StigString -split '\n')
        return ( Test-MultiplePermissionRule -PermissionPath $permissionPaths )
    }

    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultiplePermissionRule -CheckContent ($CheckContent -split '\n') )
    }
}
#endregion
#region Method Functions
<#
    .SYNOPSIS
        Parses the rawString from the rule to retrieve the PermissionTargetPath
#>
function Get-PermissionTargetPath
{
    [CmdletBinding()]
    [OutputType( [string] )]
    Param
    (
        [parameter( Mandatory = $true )]
        [AllowEmptyString()]
        [string[]]
        $StigString
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    switch ($StigString)
    {
        # Do not use $env: for environment variables. They will not be able to be converted to text for XML.
        # get path for permissions that pertains to event logs
        { $stigString -match $script:RegularExpression.WinEvtDirectory }
        {
            $parentheseMatch = $StigString | Select-String -Pattern $script:RegularExpression.textBetweenParentheses

            if ( $StigString -match $script:RegularExpression.dnsServerLog )
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
        { $StigString -match $script:RegularExpression.eventViewer }
        {
            $permissionTargetPath = '%windir%\SYSTEM32\eventvwr.exe'
            break
        }

        # get path that pertains to C:\

        { $StigString -match $script:RegularExpression.cDrive }
        {
            $permissionTargetPath = '%SystemDrive%\'
            break
        }

        # get path that pertains to Sysvol
        { $StigString -match $script:RegularExpression.SysVol}
        {
            $permissionTargetPath = '%windir%\sysvol'
            break
        }

        # get path that pertains to  C:\Windows
        { $StigString -match $script:RegularExpression.systemRoot }
        {
            $permissionTargetPath = '%windir%'
            break
        }

        # get path that pertains to registry Installed Components key
        { $StigString -match $script:RegularExpression.permissionRegistryInstalled }
        {
            $permissionTargetPath = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Installed Components\'
            break
        }

        # get path that pertains to registry Winlogon key
        { $StigString -match $script:RegularExpression.permissionRegistryWinlogon }
        {
            $permissionTargetPath = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Winlogon\'
            break
        }

        # get path that pertains to registry WinReg key
        { $StigString -match $script:RegularExpression.permissionRegistryWinreg }
        {
            $permissionTargetPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\'
            break
        }

        # get path that pertains to registry NTDS key
        { $StigString -match $script:RegularExpression.permissionRegistryNTDS }
        {
            $permissionTargetPath = '%windir%\NTDS\*.*'
            break
        }

        # get path that pertains to both program files directories
        { $StigString -match $script:RegularExpression.programFiles }
        {
            $permissionTargetPath = '%ProgramFiles%;%ProgramFiles(x86)%'
            break
        }

        # get crypto folder path
        { $StigString -match $script:RegularExpression.cryptoFolder }
        {
            $permissionTargetPath = '%ALLUSERSPROFILE%\Microsoft\Crypto\Keys'
            break
        }

        # get path that pertains to Admin Shares
        { $StigString -match $Script:RegularExpression.adminShares }
        {
            $permissionTargetPath = $null
            break
        }

        # get Active Directory Path
        { $stigString -match $script:RegularExpression.ADAuditPath }
        {
            $ADPath = (Select-String -InputObject $stigString -Pattern $script:RegularExpression.ADAuditPath) -replace $script:RegularExpression.ADAuditPath, "" -replace " object.*", ""
            $permissionTargetPath = $script:ADAuditPath.$($ADPath.Trim())
            break
        }

        # get HKLM\Security path
        {
            $StigString -match $script:RegularExpression.hklmSecurity -and
            $StigString -match $script:RegularExpression.hklmSoftware -and
            $StigString -match $script:RegularExpression.hklmSystem
        }
        {
            $permissionTargetPath = 'HKLM:\SECURITY;HKLM:\SOFTWARE;HKLM:\SYSTEM'
            break
        }

        # get the individual HKLM paths
        { $StigString -match $script:RegularExpression.hklmSecurity }
        {
            $permissionTargetPath = 'HKLM:\SECURITY'
        }

        { $StigString -match $script:RegularExpression.hklmSoftware }
        {
            $permissionTargetPath = 'HKLM:\SOFTWARE'
        }

        { $StigString -match $script:RegularExpression.hklmSystem }
        {
            $permissionTargetPath = 'HKLM:\SYSTEM'
        }

        # get path for C:, Program file, and Windows
        {
            $StigString -match $script:RegularExpression.rootOfC -and
            $StigString -match $script:RegularExpression.winDir -and
            $StigString -match $script:RegularExpression.programFilesWin10
        }
        {
            $permissionTargetPath = '%SystemDrive%;%ProgramFiles%;%Windir%'
            break
        }
        {
            $StigString -match $script:RegularExpression.rootOfC -and
            $StigString -notmatch $script:RegularExpression.winDir -and
            $StigString -notmatch $script:RegularExpression.programFileFolder
        }
        {
            $permissionTargetPath = '%SystemDrive%'
            break
        }
        { $stigString -match $script:RegularExpression.winDir }
        {
            $permissionTargetPath = '%Windir%'
            break
        }
        {  $stigString -match $script:RegularExpression.programFileFolder }
        {
            $permissionTargetPath = '%ProgramFiles%'
            break
        }
        { $stigString -match $script:RegularExpression.programFiles86 }
        {
            $permissionTargetPath = '%ProgramFiles(x86)%'
            break
        }
        { $stigString -match $script:RegularExpression.inetpub }
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
    [OutputType( [string] )]
    Param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $StigString
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    switch ($StigString)
    {
        { $StigString -match $script:RegularExpression.permissionRegistryWinlogon }
        {
            <#
            Permission rule that pertains to HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\
            This rule has an edge case which specifies the same inheritence to all the principals
            and is not in the same format as the other rules.
            #>
            return ConvertTo-AccessControlEntry -StigString $StigString -InheritenceInput 'This key and subkeys'
        }

        { $StigString -match $script:RegularExpression.InheritancePermissionMap }
        {
            return ConvertTo-AccessControlEntryIF -StigString $StigString
        }

        { $StigString -join " " -match $script:RegularExpression.TypePrincipalAccess}
        {
            return ConvertTo-AccessControlEntryGrouped -StigString $StigString
        }

        { $StigString -match $script:RegularExpression.cryptoFolder }
        {
            $cryptoFolderStigString = "SYSTEM, Administrators - Full Control - This folder, subfolders and files"
            return ConvertTo-AccessControlEntry -StigString $cryptoFolderStigString
        }

        { $StigString -match $script:RegularExpression.inetpub }
        {
            # in IIS Server Stig rule V-76745 says creator/owner should have special permissions to subkeys so we ignore it. All rules that are properly documented are converted
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
        This function converts the raw text from the STIG rule to a hastable with
        the following keys: Princiapl,FileSystemRights, and Inheritance. This is to
        handle scenarios where a target has multiple principals assigned permissions
        to it.
#>

function ConvertTo-AccessControlEntryGrouped
{
    [CmdletBinding()]
    [OutputType( [hashtable] )]
    param
    (
        [psobject] $StigString,

        [string] $InheritenceInput
    )

    $accessControlEntryPrincipal = $StigString | Select-String -Pattern "Principal\s*-"
    $accessControlEntryType = $StigString | Select-String -Pattern "Type\s*-"
    $accessControlEntryAccess = $StigString | Select-String -Pattern "Access\s*-"
    $accessControlEntryApplies = $StigString | Select-String -Pattern "Applies To\s*-"
    $accessControlEntrySpecial = $StigString | Select-String -Pattern "\(Access - Special\s*"

    foreach ($entry in $accessControlEntryType)
    {
        $Type = ($entry.ToString() -Split "-")[1].Trim()
        $PrincipalObject = $accessControlEntryPrincipal | Where-Object {$_.LineNumber -gt $entry.LineNumber} | Sort-Object -Property LineNumber | Select-Object -First 1
        $Principal = ($PrincipalObject.ToString() -split '-')[1].Trim()
        $RightsObject = $accessControlEntryAccess | Where-Object {$_.LineNumber -gt $entry.LineNumber} | Sort-Object -Property LineNumber | Select-Object -First 1
        $Rights = ($RightsObject.ToString() -split "-")[1].Trim()
        $InheritanceObject = $accessControlEntryApplies | Where-Object {$_.LineNumber -gt $RightsObject.LineNumber} | Sort-Object -Property LineNumber | Select-Object -First 1
        if($InheritanceObject)
        {
            $Inheritance = ($InheritanceObject.ToString() -split "-")[1].Trim()
        }
        else
        {
            $inheritance = ""
        }

        if ($Rights -eq "Special")
        {
            $specialPermissions = $accessControlEntrySpecial | Where-Object {$_.LineNumber -gt $RightsObject.LineNumber} | Sort-Object -Property LineNumber | Select-Object -First 1
            if ($specialPermissions.ToString().Contains(':'))
            {
                $Rights = ($specialPermissions -split ':')[1].Trim()
            }
            else
            {
                $Rights = ($specialPermissions -split '=')[1].Trim()
            }
            $Rights = $Rights.Substring(0,$Rights.Length -1)
        }

        $accessControlEntries += [pscustomobject[]]@{
            Principal        = $Principal
            ForcePrincipal   = Get-ForcePrincipal($StigString)
            Rights           = Convert-RightsConstant -RightsString $Rights
            Inheritance      = $script:inheritenceConstant[[string]$Inheritance.trim()]
            Type             = $Type
        }
    }
    return $accessControlEntries
}

function ConvertTo-AccessControlEntryIF
{
    [CmdletBinding()]
    [OutputType( [hashtable] )]
    param
    (
        [psobject] $StigString,

        [string] $InheritenceInput
    )

    $accessControlEntryMatches = $StigString | Select-String -Pattern $script:RegularExpression.InheritancePermissionMap
    $permissions = $StigString | Select-String -Pattern $script:RegularExpression.PermissionRuleMap

    foreach ($entry in $accessControlEntryMatches)
    {
        $entry = $entry -replace ':', ' - ' -replace '\)\s*\(', ') - ('
        foreach ($permission in $permissions)
        {
            $perm = $permission -split '-'
            $perm[0] = $perm[0] -replace '\(','\(' -replace '\)','\)'
            $entry = $entry -replace $perm[0].Trim(), $perm[1].Trim()
        }
        $principal, [string]$inheritance, $fileSystemRights = $entry -split $script:RegularExpression.spaceDashSpace
        if (-not $script:inheritenceConstant[[string]$inheritance.trim()])
        {
            $inheritance = ""
        }
        else
        {
            $inheritance = $script:inheritenceConstant[[string]$inheritance.trim()]
        }
        $accessControlEntries += [pscustomobject[]]@{
            Principal        = $principal.trim()
            ForcePrincipal   = Get-ForcePrincipal($StigString)
            Rights           = Convert-RightsConstant -RightsString $fileSystemRights
            Inheritance      = $inheritance
        }
    }
    return $accessControlEntries
}

function ConvertTo-AccessControlEntry
{
    [CmdletBinding()]
    [OutputType( [hashtable] )]
    param
    (
        [psobject] $StigString,

        [string] $InheritenceInput
    )

    $accessControlEntryMatches = $StigString | Select-String -Pattern $script:RegularExpression.spaceDashSpace

    foreach ( $entry in $accessControlEntryMatches )
    {
        if ( $entry -notmatch 'Type|Inherited|Columns|Principal|Applies' )
        {
            # Access control entries are commonly formated like so: 'Princiapl - FileSystemRights - Inheritance
            # we will split on a regex pattern the represents space dash space ( - )
            $principals, $fileSystemRights, [string]$inheritance = $entry -split $script:RegularExpression.spaceDashSpace

            if ( $fileSystemRights -match $Script:RegularExpression.textBetweenParentheses )
            {
                $inheritance = [regex]::Match( $fileSystemRights, $script:RegularExpression.textBetweenParentheses ).groups[1].Value

                $fileSystemRights = ($fileSystemRights -split '\(')[0]
            }

            # There is an edge case V-63593 which states the rights should be 'Special' but it doesn't state what the special rights should be so we ignore it.
            if ( $StigString -match $script.$script:RegularExpression.hklmRootKeys -and $fileSystemRights.Trim() -eq 'Special')
            {
                break
            }
            <#
            There is an edge case in V-26070 where the inheritance is specified in the rule outside of the common format
            V-26070 states the inheritance is to be applied to all the prinicpals.  So if an inheritance is passed in from the Inheritance
            parameter we applied to all the prinicipals.  If not we parse the rawString to extract the inheritance.
            #>
            if ( $InheritenceInput )
            {
                $inheritance = $InheritenceInput
            }

            foreach ( $principal in $principals -split ',' )
            {
                $accessControlEntries += [pscustomobject[]]@{
                    Principal      = $principal.trim()
                    ForcePrincipal = Get-ForcePrincipal($StigString)
                    Rights         = Convert-RightsConstant -RightsString $fileSystemRights
                    Inheritance    = $script:inheritenceConstant[[string]$inheritance.trim()]
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
    [OutputType( [array] )]
    param
    (
        [string] $RightsString
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
        [string] $PermissionPath
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
    if ( $CheckContent -match $script:RegularExpression.hklmRootKeys )
    {
        $hklmSecurityMatch = $CheckContent | Select-String -Pattern $script:RegularExpression.hklmSecurity
        $hklmSoftwareMatch = $CheckContent | Select-String -Pattern $script:RegularExpression.hklmSoftware
        $hklmSystemMatch   = $CheckContent | Select-String -Pattern $script:RegularExpression.hklmSystem

        [void]$contentRanges.Add(($hklmSecurityMatch.LineNumber - 1)..($hklmSoftwareMatch.LineNumber - 2))
        [void]$contentRanges.Add(($hklmSoftwareMatch.LineNumber - 1)..($hklmSystemMatch.LineNumber - 2))
        [void]$contentRanges.Add(($hklmSystemMatch.LineNumber - 1)..($checkContent.Length - 4))

        $headerLineRange = 0..($hklmSecurityMatch.LineNumber - 2)
        $footerLineRange = ($CheckContent.Length - 4)..($CheckContent.Length + 1)
    }
    elseIf ( $CheckContent -match $script:RegularExpression.rootOfC -and
        $CheckContent -match $script:RegularExpression.programFilesWin10 -and
        $CheckContent -match $script:RegularExpression.winDir
    )
    {
        $rootOfCMatch = $CheckContent | Select-String -Pattern $script:RegularExpression.rootOfC | Select-Object -First 1
        $programFilesMatch = $CheckContent | Select-String -Pattern $script:RegularExpression.programFileFolder
        $windowsDirectoryMatch = $CheckContent | Select-String -Pattern $script:RegularExpression.winDir
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
