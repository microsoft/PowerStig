#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

Access the IIS 8.5 web server IIS 8.5 Manager.

Under "IIS" double-click on the "Logging" icon.

In the "Logging" configuration box, determine the "Directory:" to which the "W3C" logging is being written.

Confirm with the System Administrator that the designated log path is of sufficient size to maintain the logging.

Under "Log File Rollover", verify the "Do not create new log files" is not selected.

Verify a schedule is configured to rollover log files on a regular basis.

Consult with the System Administrator to determine if there is a documented process for moving the log files off of the IIS 8.5 web server to another logging device.'
#endregion
#region Tests

Describe "ConvertTo-IisLoggingRule" {
    $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
    $rule = ConvertTo-IisLoggingRule -StigRule $stigRule

    It "Should return an IisLoggingRule object" {
        $rule.GetType() | Should Be 'IisLoggingRule'
    }
}
#endregion Function Tests
