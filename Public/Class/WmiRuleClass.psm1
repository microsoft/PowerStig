# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\common\enum.psm1
using module .\StigClass.psm1
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
