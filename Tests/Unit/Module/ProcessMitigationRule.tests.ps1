#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                MitigationTarget = 'System'
                MitigationType = 'Heap'
                MitigationName = 'TerminateOnError'
                MitigationValue = 'true'
                OrganizationValueRequired = $false
                CheckContent = ' This is NA prior to v1709 of Windows 10.

                Run "Windows PowerShell" with elevated privileges (run as administrator).

                Enter "Get-ProcessMitigation -System".

                If the status of "Heap: TerminateOnError" is "OFF", this is a finding.

                Values that would not be a finding include:
                ON
                NOTSET'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
