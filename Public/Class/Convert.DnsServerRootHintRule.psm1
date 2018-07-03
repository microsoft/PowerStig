#region Header V1
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\Common.Enum.psm1
using module .\Convert.Stig.psm1
using module .\..\Data\Convert.Main.psm1
# Additional required modules

#endregion
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
