#region Header V1
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\Common.Enum.psm1
using module .\Convert.Stig.psm1
using module .\..\Data\Convert.Data.psm1
# Additional required modules

#endregion
#region Class Definition
Class WmiRule : STIG
{
    [string] $Query
    [string] $Property
    [string] $Value
    [string] $Operator

    # Constructor
    WmiRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
}
#endregion
