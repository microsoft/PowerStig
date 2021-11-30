#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try 
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                ProtocolName = 'NamedPipes'
                Enabled      = 'False'
                CheckContent                   = 'To determine the protocol(s) enabled for SQL Server, open SQL Server Configuration Manager. 
                In the left-hand pane, expand SQL Server Network Configuration. Click on the entry for the SQL Server instance under review: "Protocols for ". 
                The right-hand pane displays the protocols enabled for the instance.
 
                If Named Pipes is enabled and not specifically required and authorized, this is a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'Method Function Tests' {
            foreach ($testRule in $testRuleList)
            {

                $protocolName = Get-ProtocolName -CheckContent $testRule.CheckContent

                Context "SqlProtocol Get-ProtocolName"{
                    It "Should return $($protocolName)" {
                        $protocolName | Should Be $testrule.ProtocolName
                    }
                }

                $enabledStatus = Set-Enabled -CheckContent $testRule.CheckContent

                Context "SqlProtocol Set-Enabled" {
                    It "Should return $($enabledStatus)" {
                        $enabledStatus | Should Be $testrule.Enabled
                    }
                }

                . $PSScriptRoot\Convert.CommonTests.ps1

            }
        } 
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
