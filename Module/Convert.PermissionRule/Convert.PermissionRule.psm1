# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into a permission object
    .DESCRIPTION
        The PermissionRule class is used to extract the permission settings
        from the check-content of the xccdf. Once a STIG rule is identified a
        permission rule, it is passed to the PermissionRule class for parsing
        and validation.
    .PARAMETER Path
        The path to the object the permissions apply to
    .PARAMETER AccessControlEntry
        The ACE to be set on the path property
    .PARAMETER Force
        A flag that will overwrite the current ACE in the ACL instead of merge
#>
Class PermissionRule : Rule
{
    [string] $Path
    [object[]] $AccessControlEntry
    [bool] $Force

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts an xccdf stig rule element into a PermissionRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    PermissionRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass($StigRule)
    }

    # Methods

    <#
        .SYNOPSIS
            Extracts the object path from the check-content and sets the value
        .DESCRIPTION
            Gets the object path from the xccdf content and sets the value.
            If the object path that is returned is not valid, the parser
            status is set to fail
    #>
    [void] SetPath ( )
    {
        $thisPath = Get-PermissionTargetPath -StigString $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPath ) )
        {
            $this.set_Path( $thisPath )
        }
    }

    <#
        .SYNOPSIS
            Sets the force flag
        .DESCRIPTION
            For now we're setting a default value. Later there could be
            additional logic here
    #>
    [void] SetForce ( )
    {
        $this.set_Force($true)
    }

    <#
        .SYNOPSIS
            Extracts the ACE from the check-content and sets the value
        .DESCRIPTION
            Gets the ACE from the xccdf content and sets the value. If the ACE
            that is returned is not valid, the parser status is set to fail
    #>
    [void] SetAccessControlEntry ( )
    {
        $thisAccessControlEntry = Get-PermissionAccessControlEntry -StigString $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisAccessControlEntry ) )
        {
            foreach ( $principal in $thisAccessControlEntry.Principal )
            {
                $this.SetStatus( $principal )
            }

            foreach ( $rights in $thisAccessControlEntry.Rights )
            {
                if ( $rights -eq 'blank' )
                {
                    $this.SetStatus( "", $true )
                    continue
                }
                $this.SetStatus( $rights )
            }

            $this.set_AccessControlEntry( $thisAccessControlEntry )
        }
    }

    <#
        .SYNOPSIS
            Tests if a rules contains more than one check
        .DESCRIPTION
            Gets the path defined in the rule from the xccdf content and then
            checks for the existance of multuple entries.
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        $permissionPaths = Get-PermissionTargetPath -StigString ([Rule]::SplitCheckContent( $CheckContent ) )
        return ( Test-MultiplePermissionRule -PermissionPath $permissionPaths )
    }

    <#
        .SYNOPSIS
            Splits mutiple paths from a singel rule into multiple rules
        .DESCRIPTION
            Once a rule has been found to have multiple checks, the rule needs
            to be split. This method splits a permission check into multiple rules.
            Each split rule id is appended with a dot and letter to keep reporting
            per the ID consistent. An example would be is V-1000 contained 2
            checks, then SplitMultipleRules would return 2 objects with rule ids
            V-1000.a and V-1000.b
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultiplePermissionRule -CheckContent ([Rule]::SplitCheckContent( $CheckContent ) ) )
    }

    #endregion
}
