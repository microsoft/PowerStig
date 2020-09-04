#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                OrganizationValueRequired = $false
                CheckContent = 'Determine whether any shared accounts exist. If no shared accounts exist, this is NA.

                Shared accounts, such as required by an application, may be approved by the organization.  This must be documented with the ISSO. Documentation must include the reason for the account, who has access to the account, and how the risk of using the shared account is mitigated to include monitoring account activity.

                If unapproved shared accounts exist, this is a finding.'
            }
            @{
                Id = "V-7069"
                Severity = "medium"
                title="APPNET0055 CAS and Policy Config File Backups"
                Dscresource = "None"
                OrganizationValueRequired = $false
                CheckContent = 'Ask the System Administrator if all CAS policy and policy configuration files are included in the system backup. If they are not, this is a finding.

                Ask the System Administrator if the policy and configuration files are backed up prior to migration, deployment, and reconfiguration. If they are not, this is a finding.

                Ask the System Administrator for documentation that shows CAS Policy configuration files are backed up as part of a disaster recovery plan. If they have no documentation proving the files are backed up, this is a finding.'
                RawString = 'Ask the System Administrator if all CAS policy and policy configuration files are included in the system backup. If they are not, this is a finding.

                Ask the System Administrator if the policy and configuration files are backed up prior to migration, deployment, and reconfiguration. If they are not, this is a finding.

                Ask the System Administrator for documentation that shows CAS Policy configuration files are backed up as part of a disaster recovery plan. If they have no documentation proving the files are backed up, this is a finding.'
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
