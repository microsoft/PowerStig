# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule\Rule.psm1
using module .\..\SqlDatabaseRule.psm1

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
        Convert the contents of an xccdf check-content element into a SqlDatabaseRule
    .DESCRIPTION
        The SqlDatabaseRule class is used to extract the vulnerability ID's that can
        be set with the SqlServerDsc module from the check-content of the xccdf. 
        Once a STIG rule is identified a SqlServerDsc rule, it is passed to the SqlDatabaseRule 
        class for parsing and validation.
#>

class SqlDatabaseRuleConvert : SqlDatabaseRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SqlDatabaseRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SqlProtocol Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>

    SqlDatabaseRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetName()
        $this.SetEnsure()
        $this.SetDscResource()
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the mitigation target name from the check-content and sets
            the value
        .DESCRIPTION
            Gets the mitigation target name from the xccdf content and sets the
            value. If the mitigation target name that is returned is not valid,
            the parser status is set to fail
    #>

    [void] SetName ()
    {
        $thisName = Get-DatabaseName -CheckContent $this.RawString

        if (-not $this.SetStatus($thisName))
        {
            $this.set_Name($thisName)
        }
    }

    [void] SetEnsure ()
    {
        $thisEnsure = Set-Ensure -CheckContent $this.rawstring

        if (-not $this.SetStatus($thisEnsure))
        {
            $this.set_Ensure($thisEnsure)
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $checkContent -Match 'If this system is identified as production' -or
            $checkcontent -Match 'the existance of the publicly available'
        )
        {
            return $true
        }
        
        return $false
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'SqlDatabase'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }

    <#
        .SYNOPSIS
            Tests if a rule contains multiple checks
        .DESCRIPTION
            Search the rule text to determine if multiple mitigationsare defined
        .PARAMETER MitigationTarget
            The object the mitigation applies to
    #>
    <#{TODO}#> # HasMultipleRules is implemented inconsistently.
    static [bool] HasMultipleRules ([string] $CheckContent)
    {
        return Test-MultipleSqlDatabase -CheckContent ([SqlDatabaseRule]::SplitCheckContent($CheckContent))
    }

    <#
        .SYNOPSIS
            Splits a rule into multiple checks
        .DESCRIPTION
            Once a rule has been found to have multiple checks, the rule needs
            to be split. This method splits a {0} into multiple rules. Each
            split rule id is appended with a dot and letter to keep reporting
            per the ID consistent. An example would be is V-1000 contained 2
            checks, then SplitMultipleRules would return 2 objects with rule ids
            V-1000.a and V-1000.b
        .PARAMETER MitigationTarget
            The object the mitigation applies to
    #>
    static [string[]] SplitMultipleRules ([string] $CheckContent)
    {
       return Split-MultipleSqlDatabase -CheckContent $CheckContent
    }
}
