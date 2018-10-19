# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

data DnsServerSetting
{
    ConvertFrom-StringData @'
        Event Logging = EventLogLevel
        Forwarders    = NoRecursion
'@
}
