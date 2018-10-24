# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

data serviceRegEx
{
    ConvertFrom-StringData -stringdata @'
        McAfee                  = McAfee Agent
        SmartCardRemovalPolicy  = Smart Card Removal Policy
        SecondaryLogon          = Secondary Logon
        followingservices       = Verify the Startup Type for the following Windows services:
'@
}

data ServicesDisplayNameToName
{
    ConvertFrom-StringData -stringdata @'
        Active Directory Domain Services = NTDS
        DFS Replication                  = DFSR
        DNS Client                       = Dnscache
        DNS Server                       = DNS
        Group Policy Client              = gpsvc
        Intersite Messaging              = IsmServ
        Kerberos Key Distribution Center = Kdc
        Windows Time                     = W32Time
'@
}
