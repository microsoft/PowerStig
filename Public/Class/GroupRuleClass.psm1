# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\common\enum.psm1
using module .\StigClass.psm1
. $PSScriptRoot\..\common\data.ps1
#endregion
#region Class Definition
Class GroupRule:STIG
{
    [string] $GroupName
    [string[]] $MembersToExclude

    # Constructor
    GroupRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass($StigRule)
    }

    # Methods
    [void] SetGroupName ()
    {
        $thisGroupDetails = Get-GroupDetail -CheckContent $this.rawString

        if ( -not $this.SetStatus( $thisGroupDetails.GroupName ) )
        {
            $this.set_GroupName( $thisGroupDetails.GroupName )
        }
    }

    [void] SetMembersToExclude ()
    {
        if ($this.rawString -match 'Domain Admins group must be replaced')
        {
            $thisGroupMember = (Get-GroupDetail -CheckContent $this.rawString).Members
        }
        else
        {
            $thisGroupMember = $null
        }
        if ( -not $this.SetStatus( $thisGroupMember ) )
        {
            $this.set_MembersToExclude( $thisGroupMember )
        }
    }
}
#endregion
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the Group Details (GroupName and MembersToExclude) from the STIG rule check-content
    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-GroupDetail
{
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    $srcRoot = Split-Path -Path $PSScriptRoot | Split-Path
    $templateFile = Join-Path -Path $srcRoot -ChildPath 'templates\groupRuleTemplate.txt'
    $result = $CheckContent | ConvertFrom-String -TemplateFile $templateFile

    return $result
}
#endregion
