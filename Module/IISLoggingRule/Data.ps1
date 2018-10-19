# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

data logflagsConstant
{
    ConvertFrom-StringData -stringdata @'
        Client IP Address = ClientIP
        Date              = Date
        Method            = Method
        Protocol Status   = ProtocolVersion
        Referrer          = Referer
        and Referrer      = Referer
        Time              = Time
        URI Query         = UriQuery
        User Agent        = UserAgent
        User Name         = UserName
'@
}
