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
            },
            @{
                FilePath                  = '/etc/audit/rules.d/audit.rules'
                ContainsLine              = '-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k setuid'
                DoesNotContainPattern     = '#\s*-a\s*always,exit\s*-F\s*arch\s*=\s*b32\s*-S\s*execve\s*-C\s*uid!\s*=\s*euid\s*-F\s*euid\s*=\s*0\s*-k\s*setuid'
                OrganizationValueRequired = $false
                CheckContent              = 'Verify the operating system audits the execution of privileged functions using the following command:

                # grep -iw execve /etc/audit/audit.rules

                -a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k setuid

                If both the "b32" and "b64" audit rules for "SUID" files are not defined, this is a finding.'
            },
            @{
                FilePath                  = '/etc/pam.d/passwd'
                ContainsLine              = 'password substack system-auth'
                DoesNotContainPattern     = '^\s*password\s\s+substack\s\s+system-auth\s*$|^#\s*password\s*substack\s*system-auth.*'
                OrganizationValueRequired = $false
                CheckContent              = 'Verify that /etc/pam.d/passwd is configured to use /etc/pam.d/system-auth when changing passwords:
                # grep /etc/pam.d/passwd
                password     substack     system-auth
                If no results are returned, the line is commented out, this is a finding.'
            },
            @{
                FilePath                    = '/etc/pam.d/system-auth'
                ContainsLine                = ''
                DoesNotContainPattern       = ''
                OrganizationValueRequired   = $true
                OrganizationValueTestString = 'that the following statement is true when leveraging the correct nxFileLine ContainsLine format: "If the value of "retry" is set to "0" or greater than "3", this is a finding" '
                CheckContent                = 'Verify the operating system uses "pwquality" to enforce the password complexity rules.

                Check for the use of "pwquality" with the following command:

                # cat /etc/pam.d/system-auth | grep pam_pwquality

                password required pam_pwquality.so retry=3

                If the command does not return an uncommented line containing the value "pam_pwquality.so", this is a finding.

                If the value of "retry" is set to "0" or greater than "3", this is a finding'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        Describe 'MultipleRules' {
            $testRuleList = @(
                @{
                    Count = 4
                    CheckContent = 'Verify the operating system audits the execution of privileged functions using the following command:

                    # grep -iw execve /etc/audit/audit.rules

                    -a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k setuid
                    -a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k setuid
                    -a always,exit -F arch=b32 -S execve -C gid!=egid -F egid=0 -k setgid
                    -a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k setgid


                    If both the "b32" and "b64" audit rules for "SUID" files are not defined, this is a finding.

                    If both the "b32" and "b64" audit rules for "SGID" files are not defined, this is a finding.'
                }
            )

            foreach ($testRule in $testRuleList)
            {
                It "Should return $true" {
                    $multipleRule = [nxFileLineRuleConvert]::HasMultipleRules($testRule.CheckContent)
                    $multipleRule | Should -Be $true
                }
                It "Should return $($testRule.Count) rules" {
                    $multipleRule = [nxFileLineRuleConvert]::SplitMultipleRules($testRule.CheckContent)
                    $multipleRule.count | Should -Be $testRule.Count
                }
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
