# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    This is used to centralize the regEx patterns, note that the backslashes are
    escaped, a single "\s" would be represented as "\\s"
#>
data regularExpression
{
    ConvertFrom-StringData -StringData @'
        nxFileLineContainsLine        = .*\\n(?<setting>.*\\n|.*\\n.*\\n|.*\\n.*\\n.*\\n)If.*this is a finding
        nxFileLineContainsLineExclude = The result must contain the following line:
        nxFileLineFilePath            = #.*\\s(?<filePath>\\/[\\w.\\/-]*\\/[\\w.\\/-]*)
'@
}

<#
    The doesNotContainPattern variable is used by Get-nxFileLineDoesNotContainPattern
#>
data doesNotContainPattern
{
    @{
        'active = yes'                                                                         = 'active\s*=\s*no|active=yes'
        'remote_server = 192.168.122.126'                                                      = 'TestReturnValue'
        'Unattended-Upgrade::Remove-Unused-Dependencies "true";'                               = 'Unattended-Upgrade::Remove-Unused-Dependencies\s*("false"|false)\s*;'
        'Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";'                            = 'Unattended-Upgrade::Remove-Unused-Kernel-Packages\s*("false"|false)\s*;'
        'session required pam_lastlog.so showfailed'                                           = 'session\s*(?!required)\w*\s*pam_lastlog\.so\s*showfailed'
        'ucredit=-1'                                                                           = 'ucredit=(?!-1)\d*'
        'lcredit=-1'                                                                           = 'lcredit=(?!-1)\d*'
        'dcredit=-1'                                                                           = 'dcredit=(?!-1)\d*'
        'difok=8'                                                                              = '^difok=(-|)[0-7]$'
        'PASS_MIN_DAYS 1'                                                                      = 'TestReturnValue'
        'PASS_MAX_DAYS 60'                                                                     = 'TestReturnValue'
        'password [success=1 default=ignore] pam_unix.so sha512 shadow remember=5 rounds=5000' = 'TestReturnValue'
        'minlen=15'                                                                            = 'TestReturnValue'
        'password [success=1 default=ignore] pam_unix.so obscure sha512'                       = 'TestReturnValue'
        'ENCRYPT_METHOD SHA512'                                                                = 'TestReturnValue'
        'dictcheck=1'                                                                          = 'TestReturnValue'
        'enforcing = 1'                                                                        = 'TestReturnValue'
        'password requisite pam_pwquality.so retry=3'                                          = 'TestReturnValue'
        'ocredit=-1'                                                                           = 'TestReturnValue'
        'action_mail_acct = root'                                                              = 'TestReturnValue'
        'disk_full_action = HALT'                                                              = 'TestReturnValue'
        '* hard maxlogins 10'                                                                  = 'TestReturnValue'
        'TMOUT=900'                                                                            = 'TestReturnValue'
        'readonly TMOUT'                                                                       = 'TestReturnValue'
        'export TMOUT'                                                                         = 'TestReturnValue'
        'ClientAliveInterval 600'                                                              = 'TestReturnValue'
        'Protocol 2'                                                                           = 'TestReturnValue'
        'ClientAliveCountMax 1'                                                                = 'TestReturnValue'
        'PermitEmptyPasswords no'                                                              = 'TestReturnValue'
        'PermitUserEnvironment no'                                                             = 'TestReturnValue'
        'cert_policy = ca,signature,ocsp_on;'                                                  = 'TestReturnValue'
        'INACTIVE=35'                                                                          = 'TestReturnValue'
        'UMASK 077'                                                                            = 'TestReturnValue'
    }
}
