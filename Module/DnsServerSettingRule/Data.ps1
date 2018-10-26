# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# This is used to centralize the regEx patterns
data RegularExpression
{
    ConvertFrom-StringData -stringdata @'
        allEvents = \\"All\\sevents\\"
        nonLetters = [^a-zA-Z ]
        textBetweenTheTab = the\\s(?s)(.*)tab\\.
'@
}

data DnsServerSetting
{
    ConvertFrom-StringData @'
        Event Logging = EventLogLevel
        Forwarders    = NoRecursion
'@
}
