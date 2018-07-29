# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
data ServicesDisplayNameToName
{
    ConvertFrom-StringData -stringdata @'
        Active Directory Domain Services = NTDS
        DFS Replication = DFSR
        DNS Client = Dnscache
        DNS Server = DNS
        Group Policy Client = gpsvc
        Intersite Messaging = IsmServ
        Kerberos Key Distribution Center = Kdc
        Windows Time = W32Time
'@
}
