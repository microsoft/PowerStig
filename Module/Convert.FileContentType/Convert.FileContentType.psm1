# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1

# Header

<#
    .SYNOPSIS
        Singleton class to support variable filter and parse methods in FileContentRule
    .DESCRIPTION
        The FileContentType is used to extend filter and parse logic for diiferent 
        FileContentRules without modifing existing filtering and parsing logic
    .PARAMETER instance
        Maintains a single instance of the object

#>
Class FileContentType
{
    static [FileContentType] $instance
    
    #region Constructor
    hidden FileContentType ()
    {
    }

     #region Methods

     <#
        .SYNOPSIS
            Returns an instance of the class
        .DESCRIPTION
            Gets or sets a single instance of the FileContentType
            for use in the FileContentRule 
    #>

     static [FileContentType] GetInstance()
     {
         if ([FileContentType]::instance -eq $null)
         {
             [FileContentType]::instance = [FileContentType]::new()
         }
         return [FileContentType]::instance
     }
 
    <#
        .SYNOPSIS
            Loads and applies specific filtering and parsing rules
        .DESCRIPTION
            When Key-Value settings are located in a rule, the format
            of Key-Value pairs differ between technologies, this method 
            supports a unique filter and parsing strategy for the rule 
        .PARAMETER matchResule
            The key-value settitngs from the check-content element in the xccdf
    #>

    [pscustomobject] ProcessMatches ( [psobject] $matchResult )
    {
        $exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
        $supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude -Recurse -Include "*.$($global:stigArchiveFile).*"
        Foreach ($supportFile in $supportFileList)
        {
            Write-Verbose "Loading $($supportFile.FullName)"
            . $supportFile.FullName
        }

        $filtered = Get-FilteredItems $matchResult
        if ($filtered)
        {
            return $filtered;
        } 
        else 
        {
            return $null    
        }
    }
}
