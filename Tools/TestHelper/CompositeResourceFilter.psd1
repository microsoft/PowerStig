# This hash table is used filter for applicable stig data for a specific composite resource
@{
    Browser          = @("*IE11*")
    DotNetFramework  = @("*DotNet4*")
    IisServer        = @("*IISServer*")
    IisSite          = @("*IISSite*")
    OracleJRE        = @("*OracleJRE8*")
    SqlServer        = @("*Instance*", "*Database*")
    Firefox          = @("*Firefox*")
    Office           = @("*Outlook2016", "*Excel2013*", "*Outlook2013*", "*PowerPoint2013*", "*Word2013*")
    WindowsClient    = @("*Client*")
    WindowsFirewall  = @("*FW*")
    WindowsDnsServer = @("*DNS*")
    WindowsServer    = @("*DC*", "*MS*")
}
