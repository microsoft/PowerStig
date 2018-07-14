#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
#endregion
#region Class
Class GroupRule : STIG
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
