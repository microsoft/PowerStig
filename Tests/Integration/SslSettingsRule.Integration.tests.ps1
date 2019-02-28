#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $stigRulesToTest = @(
        @{
            Value        = 'Ssl'
            CheckContent = 'Note: If the server being reviewed is a public IIS 8.5 web server, this is Not Applicable.
            
            Note: If SSL is installed on load balancer through which traffic is routed to the IIS 8.5 server, and the IIS 8.5 server ONLY receives traffic from the load balancer, the SSL requirement must be met on the load balancer.
            
            Follow the procedures below for each site hosted on the IIS 8.5 web server:
            
            Open the IIS 8.5 Manager.
            
            Click the site name.
            
            Double-click the "SSL Settings" icon.
            
            Verify "Require SSL" check box is selected.
            
            If the "Require SSL" check box is not selected, this is a finding.'
        }
    )
    #endregion
    #region Tests
    Describe 'SslSettings Rule Conversion' {

        foreach ( $stig in $stigRulesToTest )
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $stig.CheckContent -XccdfTitle 'IIS'
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should return an SslSettingsRule Object' {
                $rule.GetType() | Should Be 'SslSettingsRule'
            }
            It "Should return Value '$($stig.Value)'" {
                $rule.Value | Should Be $stig.Value
            }
            It "Should set the correct DscResource" {
                $rule.DscResource | Should Be 'xSslSettings'
            }
            It 'Should Set the status to pass' {
                $rule.ConversionStatus | Should Be 'pass'
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
