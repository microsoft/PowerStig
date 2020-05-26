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
        'active = yes'                                              = '\s*active\s*=\s*no|active=yes|#\s*active\s*=.*'
        'Unattended-Upgrade::Remove-Unused-Dependencies "true";'    = '\s*Unattended-Upgrade::Remove-Unused-Dependencies\s*("false"|false|true).*|#\s*Unattended-Upgrade::Remove-Unused-Dependencies.*'
        'Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";' = '\s*Unattended-Upgrade::Remove-Unused-Kernel-Packages\s*("false"|false|true).*|#\s*Unattended-Upgrade::Remove-Unused-Kernel-Packages.*'
        'session required pam_lastlog.so showfailed'                = '\s*session\s*(?!required)\w*\s*pam_lastlog\.so.*|#\s*session\s*\w*\s*pam_lastlog\.so.*'
        'ucredit=-1'                                                = '^\s*ucredit\s*=\s*(?!-1)\d*$|#\s*ucredit=.*'
        'lcredit=-1'                                                = '^\s*lcredit\s*=\s*(?!-1)\d*$|#\s*lcredit=.*'
        'dcredit=-1'                                                = '^\s*dcredit\s*=\s*(?!-1)\d*$|#\s*dcredit=.*'
        'difok=8'                                                   = '^\s*difok\s*=\s*(-|)[0-7]$|#\s*difok\s*=.*|difok\s+=\s+.*' # Org
        'PASS_MIN_DAYS 1'                                           = '^\s*PASS_MIN_DAYS\s*[0]*$|#\s*PASS_MIN_DAYS.*' # Org
        'PASS_MAX_DAYS 60'                                          = '^\s*PASS_MAX_DAYS\s*([0-9]|[1-5][0-9])$|#\s*PASS_MAX_DAYS.*' # Org
        'minlen=15'                                                 = '^\s*minlen\s*=\s*([0-9]|[1][1-4])$|#\s*minlen.*' # Org
        'dictcheck=1'                                               = '^\s*dictcheck\s*=\s*((?!1)|[1]\d+)\d*$|#\s*dictcheck.*'
        'enforcing = 1'                                             = '^\s*enforcing\s*=\s*((?!1)|[1]\d+)\d*$|#\s*enforcing.*'
        'ocredit=-1'                                                = '^\s*ocredit\s*=\s*(?!-1)\d*$|#\s*ocredit=.*'
        '* hard maxlogins 10'                                       = '^\s*\*\s*hard\s*maxlogins\s*([1][1-9]|[2-9]\d+|[1-9][0-9]\d+)$|^#\s*\*\s*hard\s*maxlogins.*'
        'TMOUT=900'                                                 = '^\s*TMOUT\s*=\s*[0-8]?[0-9]?[0-9]?$|^#\s*TMOUT.*' # Org
        'readonly TMOUT'                                            = '^\s*readonly\s+(?!TMOUT\b).*$|^\s*#\s*readonly.*$' # Org
        'export TMOUT'                                              = '^\s*export\s+(?!TMOUT\b).*$|^\s*#\s*export.*$' # Org
        'ClientAliveInterval 600'                                   = '^\s*ClientAliveInterval\s*[0-5]?[0-9]?[0-9]?\s*$|^#\s*ClientAliveInterval.*|^\s*ClientAliveInterval\s*$'
        'Protocol 2'                                                = '^\s*Protocol\s*([0-1]|[3-9]|\d{2,})\s*$|#\s*Protocol.*|^\s*Protocol\s*$'
        'ClientAliveCountMax 1'                                     = '^\s*ClientAliveCountMax\s*([0]|[2-9]|\d{2,})\s*$|#\s*ClientAliveCountMax.*|^\s*ClientAliveCountMax\s*$'
        'PermitEmptyPasswords no'                                   = '^\s*PermitEmptyPasswords\s*((?!no\b).)*$|^#\s*PermitEmptyPasswords.*$|^\s*PermitEmptyPasswords\s*$'
        'PermitUserEnvironment no'                                  = '^\s*PermitUserEnvironment\s*((?!no\b).)*$|^#\s*PermitUserEnvironment.*$|^\s*PermitUserEnvironment\s*$'
        'UMASK 077'                                                 = '^\s*UMASK\s*(?!077\b)\d*\s*$|^#\s*UMASK.*'
    }
}
