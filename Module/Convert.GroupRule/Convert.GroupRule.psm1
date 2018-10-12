# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into a group object
    .DESCRIPTION
        The GroupRule class is used to extract the group membership settings
        from the check-content of the xccdf. Once a STIG rule is identified as a
        group rule, it is passed to the GroupRule class for parsing
        and validation.
    .PARAMETER GroupName
        The Name of the group to configure
    .PARAMETER MembersToExclude
        The list of memmbers that are not allowed to be in the group
#>
Class GroupRule : Rule
{
    [string] $GroupName
    [string[]] $MembersToExclude

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf stig rule element into a GroupRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    GroupRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass($StigRule)
        $this.SetGroupName()
        $this.SetMembersToExclude()

        if ($this.conversionstatus -eq 'pass')
        {
            if ( $this.IsDuplicateRule( $global:stigSettings ))
            {
                $this.SetDuplicateTitle()
            }
        }
        $this.SetDscResource()
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the group name from the check-content and sets the value
        .DESCRIPTION
            Gets the group name from the xccdf content and sets the value. If
            the group that is returned is not a valid name, the parser status
            is set to fail.
    #>
    [void] SetGroupName ()
    {
        $thisGroupDetails = Get-GroupDetail -CheckContent $this.rawString

        if ( -not $this.SetStatus( $thisGroupDetails.GroupName ) )
        {
            $this.set_GroupName( $thisGroupDetails.GroupName )
        }
    }

    <#
        .SYNOPSIS
            Extracts the list of group names from the check-content and sets the value
        .DESCRIPTION
            Gets the list of group name from the xccdf content and sets the value.
            If the list that is returned is not a valid, the parser status is
            set to fail
    #>
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

    hidden [void] SetDscResource ()
    {
        $this.DscResource = 'Group'
    }
    #endregion
}
