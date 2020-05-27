# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

<#
    .SYNOPSIS
        A Linux FileLine Rule object.
    .DESCRIPTION
        The nxFileLineRule class is used to manage Linux file contents.
    .PARAMETER FilePath
        The full path to the file to manage lines in.
    .PARAMETER ContainsLine
        A line to ensure exists in the file. This line will be appended
        to the file if it does not exist in the file. ContainsLine is mandatory,
        but can be set to an empty string (ContainsLine = "") if it is not needed.
    .PARAMETER DoesNotContainPattern
        A regular expression pattern for lines that should not exist in the file.
        For any lines that exist in the file that match this regular expression,
        the line will be removed from the file.
#>
class nxFileLineRule : Rule
{
    [string] $FilePath
    [string] $ContainsLine <#(ExceptionValue)#>
    [string] $DoesNotContainPattern

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    nxFileLineRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    nxFileLineRule ([xml.xmlelement] $Rule) : base ($Rule)
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
    nxFileLineRule ([xml.xmlelement] $Rule, [switch] $Convert) : base ($Rule, $Convert)
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
