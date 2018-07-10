#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1
#endregion
#region Class
Class AuditPolicyRule : STIG
{
    [string] $Subcategory
    [string] $AuditFlag
    [string] $Ensure

    # Constructor
    AuditPolicyRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    [void] SetSubcategory ()
    {
        $thisSubcategory = Get-AuditPolicySubCategory -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisSubcategory ) )
        {
            $this.set_Subcategory( $thisSubcategory )
        }
    }

    [void] SetAuditFlag ()
    {
        $thisAuditFlag = Get-AuditPolicyFlag -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisAuditFlag ) )
        {
            $this.set_AuditFlag( $thisAuditFlag )
        }
    }

    [void] SetEnsureFlag ( [Ensure] $EnsureFlag )
    {
        $this.Ensure = $EnsureFlag
    }
}
#endregion
#region Footer
Foreach ($supportFile in (Get-ChildItem -Path $PSScriptRoot -Exclude $MyInvocation.MyCommand.Name))
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
Export-ModuleMember -Function '*' -Variable '*'
#endregion
