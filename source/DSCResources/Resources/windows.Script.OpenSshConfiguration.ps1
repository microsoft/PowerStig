# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = ($stig.RuleList | Select-Rule -Type FileContentRule).Where({
    $PSItem.DscResource -eq 'Script' -and $PSItem.FilePath -eq '%ProgramData%\ssh\sshd_config'
    })

foreach ($rule in $rules)
{
    $resourceTitle = Get-ResourceTitle -Rule $rule
    $filePath = $rule.FilePath.Replace("'", "''")
    $key = $rule.Key.Replace("'", "''")
    $value = $rule.Value.Replace("'", "''")
    $isBanner = $rule.Key -eq 'Banner'

    $scriptBlock = [scriptblock]::Create("
        Script '$resourceTitle'
        {
            GetScript =
            {
                `$path = [Environment]::ExpandEnvironmentVariables('$filePath')
                `$desiredValue = [Environment]::ExpandEnvironmentVariables('$value')
                `$line = if (Test-Path -Path `$path)
                {
                    Get-Content -Path `$path | Where-Object { `$_ -match '(?i)^\s*$key\s+' } | Select-Object -First 1
                }
                return @{ Result = [string] `$line }
            }

            TestScript =
            {
                if (-not (Get-Service -Name sshd -ErrorAction SilentlyContinue))
                {
                    return `$true
                }

                `$path = [Environment]::ExpandEnvironmentVariables('$filePath')
                `$desiredValue = [Environment]::ExpandEnvironmentVariables('$value')
                if (-not (Test-Path -Path `$path))
                {
                    return `$false
                }

                `$matchingLines = @(Get-Content -Path `$path | Where-Object { `$_ -match '(?i)^\s*$key\s+' })
                `$settingMatches = `$matchingLines.Count -eq 1 -and `$matchingLines[0] -match ('(?i)^\s*$key\s+' + [regex]::Escape(`$desiredValue) + '\s*(?:#.*)?`$')
                if (-not `$settingMatches -or -not '$isBanner')
                {
                    return `$settingMatches
                }

                `$legalNoticeText = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name LegalNoticeText -ErrorAction SilentlyContinue).LegalNoticeText
                return -not [string]::IsNullOrWhiteSpace(`$legalNoticeText) -and
                    (Test-Path -Path `$desiredValue) -and
                    (Get-Content -Path `$desiredValue -Raw) -eq `$legalNoticeText
            }

            SetScript =
            {
                if (-not (Get-Service -Name sshd -ErrorAction SilentlyContinue))
                {
                    return
                }

                `$path = [Environment]::ExpandEnvironmentVariables('$filePath')
                `$desiredValue = [Environment]::ExpandEnvironmentVariables('$value')
                if ('$isBanner')
                {
                    `$legalNoticeText = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name LegalNoticeText -ErrorAction SilentlyContinue).LegalNoticeText
                    if ([string]::IsNullOrWhiteSpace(`$legalNoticeText))
                    {
                        throw 'LegalNoticeText must be configured before the OpenSSH banner can be enforced.'
                    }
                    Set-Content -Path `$desiredValue -Value `$legalNoticeText -Encoding utf8 -NoNewline
                }

                `$content = if (Test-Path -Path `$path) { @(Get-Content -Path `$path) } else { @() }
                `$pattern = '(?i)^\s*#?\s*$key\b.*`$'
                `$replacement = '$key ' + `$desiredValue
                `$matched = `$false
                `$updatedContent = foreach (`$line in `$content)
                {
                    if (`$line -match `$pattern)
                    {
                        if (-not `$matched)
                        {
                            `$replacement
                            `$matched = `$true
                        }
                    }
                    else
                    {
                        `$line
                    }
                }
                if (-not `$matched)
                {
                    `$updatedContent += `$replacement
                }

                Set-Content -Path `$path -Value `$updatedContent -Encoding ascii
                Restart-Service -Name sshd
            }
        }
    ")

    $scriptBlock.Invoke()
}