#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        $testRuleList = @(
            @{
                DomainJoinedOnly     = $true
                RequiredArchitecture = '64-bit'
                RequiredEdition      = 'Windows 11 Enterprise'
                OrganizationValueRequired = $false
                CheckContent         = 'Verify domain-joined systems are using Windows 11 Enterprise Edition 64-bit version.

                For standalone systems, this is NA.

                Open "Settings".

                Select "System", then "About".

                If "Edition" is not "Windows 11 Enterprise", this is a finding.

                If "System type" is not "64-bit operating system...", this is a finding.'
            }
        )

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }
    }
}
finally
{
}