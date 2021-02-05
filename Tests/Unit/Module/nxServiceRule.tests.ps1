#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Enabled                   = 'False'
                Name                      = 'autofs'
                State                     = $null
                OrganizationValueRequired = $false
                FixText                   = 'Configure the operating system to disable the ability to automount devices.

                Turn off the automount service with the following commands:

                # systemctl stop autofs
                # systemctl disable autofs

                If "autofs" is required for Network File System (NFS), it must be documented with the ISSO.'
                CheckContent              = 'Verify the operating system disables the ability to automount devices.

                Check to see if automounter service is active with the following command:

                # systemctl status autofs
                autofs.service - Automounts filesystems on demand
                   Loaded: loaded (/usr/lib/systemd/system/autofs.service; disabled)
                   Active: inactive (dead)

                If the "autofs" status is set to "active" and is not documented with the Information System Security Officer (ISSO) as an operational requirement, this is a finding.'
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
