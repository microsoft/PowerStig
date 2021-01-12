#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                FilePath                  = '/etc/xinetd.d/tftp'
                ContainsLine              = 'server_args = -s /var/lib/tftpboot'
                DoesNotContainPattern     = '#\s*server_args\s*=\s*-s\s*/var/lib/tftpboot'
                OrganizationValueRequired = $false
                CheckContent              = 'Verify the TFTP daemon is configured to operate in secure mode.

                Check to see if a TFTP server has been installed with the following commands:

                # yum list installed tftp-server
                tftp-server.x86_64 x.x-x.el7 rhel-7-server-rpms

                If a TFTP server is not installed, this is Not Applicable.

                If a TFTP server is installed, check for the server arguments with the following command:

                # grep server_args /etc/xinetd.d/tftp
                server_args = -s /var/lib/tftpboot

                If the "server_args" line does not have a "-s" option and a subdirectory is not assigned, this is a finding.'
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
