# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

<#
    .SYNOPSIS
        A Linux Package Rule object.
    .DESCRIPTION
        The nxPackageRule class is used to manage Linux Packages.
    .PARAMETER Name
        The Linux package name.
    .PARAMETER Ensure
        The state the Linux package should be in.
#>
class nxPackageRule : Rule
{
    [string] $Name
    [string] $Ensure <#(ExceptionValue)#>

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    nxPackageRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    nxPackageRule ([xml.xmlelement] $Rule) : base ($Rule)
    {
    }

    <#
        .SYNOPSIS
            The Convert child class constructor
        .PARAMETER Rule
            The STIG rule to convert
        .PARAMETER Convert
            A simple bool flag to create a unique constructor signature
    #>
    nxPackageRule ([xml.xmlelement] $Rule, [switch] $Convert) : base ($Rule, $Convert)
    {
    }

    <#
        .SYNOPSIS
            Creates class specifc help content
    #>
    [hashtable] GetExceptionHelp()
    {
        if ($this.Ensure -eq 'Present')
        {
            $installState = 'Absent'
        }
        else
        {
            $installState = 'Present'
        }

        return @{
            Value = $installState
            Notes = "'Present' and 'Absent' are the only valid values."
        }
    }
}
