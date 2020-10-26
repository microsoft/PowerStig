# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

<#
    .SYNOPSIS
        A Linux FileLine Rule object.
    .DESCRIPTION
        The nxFileRule class is used to manage Linux file contents.
    .PARAMETER FilePath
        The full path to the file to manage lines in.
    .PARAMETER Contents
        The exact content a specific file should have.
#>
class nxFileRule : Rule
{
    [string] $FilePath
    [string] $Contents <#(ExceptionValue)#>

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    nxFileRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    nxFileRule ([xml.xmlelement] $Rule) : base ($Rule)
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
    nxFileRule ([xml.xmlelement] $Rule, [switch] $Convert) : base ($Rule, $Convert)
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
