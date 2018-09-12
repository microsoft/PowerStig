# This hash table is used filter for applicable stig data for a specific composite resource
@{
    Browser          = @("*IE11*")
    DotNetFramework  = @("*DotNet4*")
    SqlServer        = @("*Instance*", "*Database*")
    WindowsFirewall  = @("*FW*")
    WindowsDnsServer = @("*DNS*")
    WindowsOutlook2013 = @("*Outlook2013*")
    WindowsServer    = @("*DC*", "*MS*")
}
