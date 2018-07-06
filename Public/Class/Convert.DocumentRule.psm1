#region Header V1
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\Common.Enum.psm1
using module .\Convert.Stig.psm1
using module .\..\Data\Convert.Data.psm1
# Additional required modules

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
