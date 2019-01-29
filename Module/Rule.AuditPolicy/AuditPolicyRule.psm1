# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        Audit Policy object to manage Audit Policy STIG Rules
    .DESCRIPTION
        The AuditPolicyRule class is used to manage the Audit Policy Settings
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
    [ensure] $Ensure <#(ExceptionValue)#>

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    AuditPolicyRule () {}

    <#
        .SYNOPSIS
            The Convert child class constructor
        .PARAMETER Rule
            The STIG rule to convert
        .PARAMETER Convert
            A simple bool falg to create a unique constructor signature
    #>
    AuditPolicyRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    AuditPolicyRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.Subcategory = $Rule.Subcategory
        $this.AuditFlag   = $Rule.AuditFlag
        $this.Ensure      = $Rule.Ensure
    }

    <#
        .SYNOPSIS
            Creates the class specifc help content and passes it to the base class
            method to create the help content
    #>
    [string] GetExceptionHelpString()
    {
        if($this.Ensure -eq 'Absent')
        {
            return 'Present'
        }

        return 'Absent'
    }
}
