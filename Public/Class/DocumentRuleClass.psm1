# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\common\enum.psm1
using module .\StigClass.psm1
. $PSScriptRoot\..\common\data.ps1
#endregion
#region Class Definition
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
