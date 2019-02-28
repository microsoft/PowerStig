#region Header
using module .\..\..\..\Module\Rule.SslSettings\Convert\SslSettingsRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Value = 'Ssl'
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

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
