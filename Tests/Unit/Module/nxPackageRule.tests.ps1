#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Ensure                    = 'Absent'
                Name                      = 'rsh-server'
                OrganizationValueRequired = $false
                FixText                   = 'Configure the operating system to disable non-essential capabilities by removing the rsh-server package from the system with the following command:

                # yum remove rsh-server'
                CheckContent              = 'Check to see if the rsh-server package is installed with the following command:

                # yum list installed rsh-server

                If the rsh-server package is installed, this is a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
