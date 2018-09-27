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
        Convert the contents of an xccdf check-content element into an Audit Policy object
    .DESCRIPTION
        The AuditPolicyRule class is used to extract the Audit Policy Settings
        from the check-content of the xccdf. Once a STIG rule is identified as an
        Audit Policy rule, it is passed to the AuditPolicyRule class for parsing
        and validation.
    .PARAMETER Subcategory
        The name of the subcategory to configure
    .PARAMETER AuditFlag
        The Success or failure flag
    .PARAMETER Ensure
        A present or absent flag
#>
Class AuditPolicyRule : Rule
{
    [string] $Subcategory
    [string] $AuditFlag
    [string] $Ensure
    [String] $DscResource = 'AuditPolicySubcategory'
    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts an xccdf stig rule element into a AuditPolicyRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    AuditPolicyRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the subcategory name from the check-content and sets the value
        .DESCRIPTION
            Gets the audit policy subcategory from the xccdf content and sets the
            value. If the audit policy subcategory that is returned is not a
            valid subcategory, the parser status is set to fail.
    #>
    [void] SetSubcategory ()
    {
        $thisSubcategory = Get-AuditPolicySubCategory -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisSubcategory ) )
        {
            $this.set_Subcategory( $thisSubcategory )
        }
    }

    <#
        .SYNOPSIS
            Extracts the subcategory flag from the check-content and sets the value
        .DESCRIPTION
            Gets the audit policy flag from the xccdf content and sets the value.
            If the audit policy flag that is returned is not a valid flag, the
            parser status is set to fail.
    #>
    [void] SetAuditFlag ()
    {
        $thisAuditFlag = Get-AuditPolicyFlag -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisAuditFlag ) )
        {
            $this.set_AuditFlag( $thisAuditFlag )
        }
    }

    <#
        .SYNOPSIS
            Sets the ensure flag to the provided value
        .DESCRIPTION
            Sets the ensure flag to the provided value
        .PARAMETER EnsureFlag
            The value the Ensure flag should be set to
    #>
    [void] SetEnsureFlag ( [Ensure] $EnsureFlag )
    {
        $this.Ensure = $EnsureFlag
    }
    #endregion
}
