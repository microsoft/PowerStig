# This hash table is used filter for applicable stig data for a specific composite resource
@{
    Browser          = @("*IE*")

    SqlServer        = @("*Instance*", "*Database*")

    WindowsFirewall  = @("*FW*")

    WindowsDnsServer = @("*DNS*")

    WindowsServer    = @("*DC*", "*MS*")
}
