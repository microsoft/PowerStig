# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = ($stig.RuleList | Select-Rule -Type PermissionRule).Where({
    $PSItem.DscResource -eq 'Script' -and $PSItem.Path -match '%ProgramData%\\ssh\\'
    })

foreach ($rule in $rules)
{
    $resourceTitle = Get-ResourceTitle -Rule $rule
    $path = $rule.Path.Replace("'", "''")
    $includeAuthenticatedUsers = $rule.AccessControlEntry.Entry.Principal -contains 'Authenticated Users'
    $authenticatedUsersTest = if ($includeAuthenticatedUsers)
    {
        "@{ Sid = 'S-1-5-11'; Rights = 'ReadAndExecute' }"
    }
    else
    {
        ''
    }
    $authenticatedUsersGrant = if ($includeAuthenticatedUsers)
    {
        "'*S-1-5-11:(RX)'"
    }
    else
    {
        ''
    }

    $scriptBlock = [scriptblock]::Create("
        Script '$resourceTitle'
        {
            GetScript =
            {
                `$targets = @(Get-Item -Path ([Environment]::ExpandEnvironmentVariables('$path')) -ErrorAction SilentlyContinue)
                return @{ Result = (`$targets.FullName -join ';') }
            }

            TestScript =
            {
                if (-not (Get-Service -Name sshd -ErrorAction SilentlyContinue))
                {
                    return `$true
                }

                `$targets = @(Get-Item -Path ([Environment]::ExpandEnvironmentVariables('$path')) -ErrorAction SilentlyContinue)
                if (`$targets.Count -eq 0)
                {
                    return `$false
                }

                `$expected = @(
                    @{ Sid = 'S-1-5-18'; Rights = 'FullControl' }
                    @{ Sid = 'S-1-5-32-544'; Rights = 'FullControl' }
                    $authenticatedUsersTest
                )

                foreach (`$target in `$targets)
                {
                    `$acl = Get-Acl -LiteralPath `$target.FullName
                    `$actual = @(`$acl.GetAccessRules(`$true, `$false, [System.Security.Principal.SecurityIdentifier]))
                    if (`$actual.Count -ne `$expected.Count)
                    {
                        return `$false
                    }

                    foreach (`$entry in `$expected)
                    {
                        `$expectedRights = [System.Security.AccessControl.FileSystemRights] `$entry.Rights
                        `$matchingEntry = `$actual | Where-Object {
                            `$PSItem.IdentityReference.Value -eq `$entry.Sid -and
                            `$PSItem.AccessControlType -eq 'Allow' -and
                            `$PSItem.FileSystemRights -eq `$expectedRights -and
                            `$PSItem.InheritanceFlags -eq 'None' -and
                            `$PSItem.PropagationFlags -eq 'None'
                        }
                        if (-not `$matchingEntry)
                        {
                            return `$false
                        }
                    }
                }

                return `$true
            }

            SetScript =
            {
                if (-not (Get-Service -Name sshd -ErrorAction SilentlyContinue))
                {
                    return
                }

                `$targets = @(Get-Item -Path ([Environment]::ExpandEnvironmentVariables('$path')) -ErrorAction SilentlyContinue)
                foreach (`$target in `$targets)
                {
                    `$arguments = @(
                        `$target.FullName
                        '/inheritance:r'
                        '/grant:r'
                        '*S-1-5-18:(F)'
                        '*S-1-5-32-544:(F)'
                        $authenticatedUsersGrant
                    ) | Where-Object { -not [string]::IsNullOrWhiteSpace(`$PSItem) }
                    & icacls.exe @arguments | Out-Null
                    if (`$LASTEXITCODE -ne 0)
                    {
                        throw ""icacls failed for `$(`$target.FullName) with exit code `$LASTEXITCODE.""
                    }
                }
            }
        }
    ")

    $scriptBlock.Invoke()
}