
data DnsServerSetting
{
    ConvertFrom-StringData @'
        Event Logging = EventLogLevel
        Forwarders    = NoRecursion
'@
}
