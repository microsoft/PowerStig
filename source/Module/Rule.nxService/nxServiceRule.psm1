# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

<#
    .SYNOPSIS
        A Linux Service Rule object.
    .DESCRIPTION
        The nxServiceRule class is used to manage Linux Services.
    .PARAMETER Name
        The Linux Service name.
    .PARAMETER Ensure
        The state the Linux Service should be in.
#>
class nxServiceRule : Rule
{
    [string] $Name
    [string] $State
    [string] $Enabled <#(ExceptionValue)#>

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method.
    #>
    nxServiceRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory.
        .PARAMETER Rule
            The STIG rule to load.
    #>
    nxServiceRule ([xml.xmlelement] $Rule) : base ($Rule)
    {
    }

    <#
        .SYNOPSIS
            The Convert child class constructor.
        .PARAMETER Rule
            The STIG rule to convert.
        .PARAMETER Convert
            A simple bool flag to create a unique constructor signature.
    #>
    nxServiceRule ([xml.xmlelement] $Rule, [switch] $Convert) : base ($Rule, $Convert)
    {
    }

    <#
        .SYNOPSIS
            Creates class specifc help content.
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
