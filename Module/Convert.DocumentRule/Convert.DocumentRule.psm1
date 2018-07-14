#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
#endregion
#region Class
Class DocumentRule : STIG
{
    # Constructor
    DocumentRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    DocumentRule ( [string] $Id, [severity] $Severity, [string] $Title, [string] $RawString )
    {
        $this.Id = $Id
        $this.severity = $Severity
        $this.title = $Title
        $this.rawString = $RawString
        $this.SetStigRuleResource()
    }

    # Methods
    static [DocumentRule] ConvertFrom ( [object] $RuleToConvert )
    {
        return [DocumentRule]::New($RuleToConvert.Id, $RuleToConvert.severity,
                                   $RuleToConvert.title, $RuleToConvert.rawString)
    }
}
#endregion
