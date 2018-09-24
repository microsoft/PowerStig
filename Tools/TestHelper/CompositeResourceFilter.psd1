# This hash table is used filter for applicable stig data for a specific composite resource
@{
    Browser          = @("*IE11*")
    DotNetFramework  = @("*DotNet4*")
    IisServer        = @("*IISServer*")
    SqlServer        = @("*Instance*", "*Database*")
    Office           = @("*Excel2013*", "*Outlook2013*", "*PowerPoint2013*", "*Word2013*")
    WindowsFirewall  = @("*FW*")
    WindowsDnsServer = @("*DNS*")
    WindowsServer    = @("*DC*", "*MS*")
}
