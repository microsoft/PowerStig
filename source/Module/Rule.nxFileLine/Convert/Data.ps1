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
        'active = yes'                                                                         = '\s*active\s*=\s*no|active=yes|#\s*active\s*=.*'
        'remote_server = 192.168.122.126'                                                      = 'TestReturnValue' # Org
        'Unattended-Upgrade::Remove-Unused-Dependencies "true";'                               = '\s*Unattended-Upgrade::Remove-Unused-Dependencies\s*("false"|false|true).*|#\s*Unattended-Upgrade::Remove-Unused-Dependencies.*'
        'Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";'                            = '\s*Unattended-Upgrade::Remove-Unused-Kernel-Packages\s*("false"|false|true).*|#\s*Unattended-Upgrade::Remove-Unused-Kernel-Packages.*'
        'session required pam_lastlog.so showfailed'                                           = '\s*session\s*(?!required)\w*\s*pam_lastlog\.so.*|#\s*session\s*\w*\s*pam_lastlog\.so.*'
        'ucredit=-1'                                                                           = '^\s*ucredit\s*=\s*(?!-1)\d*$|#\s*ucredit=.*'
        'lcredit=-1'                                                                           = '^\s*lcredit\s*=\s*(?!-1)\d*$|#\s*lcredit=.*'
        'dcredit=-1'                                                                           = '^\s*dcredit\s*=\s*(?!-1)\d*$|#\s*dcredit=.*'
        'difok=8'                                                                              = '^\s*difok\s*=\s*(-|)[0-7]$|#\s*difok\s*=.*|difok\s+=\s+.*' # Org
        'PASS_MIN_DAYS 1'                                                                      = '^\s*PASS_MIN_DAYS\s*[0]*$|#\s*PASS_MIN_DAYS.*' # Org
        'PASS_MAX_DAYS 60'                                                                     = '^\s*PASS_MAX_DAYS\s*([0-9]|[1-5][0-9])$|#\s*PASS_MAX_DAYS.*' # Org
        'minlen=15'                                                                            = '^\s*minlen\s*=\s*([0-9]|[1][1-4])$|#\s*minlen.*' # Org
        'dictcheck=1'                                                                          = '^\s*dictcheck\s*=\s*((?!1)|[1]\d+)\d*$|#\s*dictcheck.*'
        'enforcing = 1'                                                                        = '^\s*enforcing\s*=\s*((?!1)|[1]\d+)\d*$|#\s*enforcing.*'
        'ocredit=-1'                                                                           = '^\s*ocredit\s*=\s*(?!-1)\d*$|#\s*ocredit=.*'
        'action_mail_acct = root'                                                              = 'TestReturnValue' # Org
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
