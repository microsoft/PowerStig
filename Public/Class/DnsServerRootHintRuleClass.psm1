
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module .\StigClass.psm1
using module ..\common\enum.psm1
#endregion Header
#region Class Definition
Class DnsServerRootHintRule : STIG
{
    [string] $HostName
    [string] $IpAddress

    # Constructors
    DnsServerRootHintRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods

}
#endregion
