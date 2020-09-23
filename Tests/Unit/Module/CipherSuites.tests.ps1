#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                SPLogLevelItemHashTable = $null
                OrganizationValueRequired = $false
                CheckContent = "Review the SharePoint server configuration to ensure designated organizational personnel are allowed to select which auditable events are to be audited by specific components of the system.

                Navigate to Central Administration.
                
                Click `"Monitoring`".
                
                Click `"Configure Diagnostic Logging`".
                
                Validate that the selected event categories and trace levels match those defined by the organization's system security plan.
                
                Remember that a base set of events are always audited.
                
                If the selected event categories/trace levels are inconsistent with those defined in the organization's system security plan, this is a finding.'"
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
