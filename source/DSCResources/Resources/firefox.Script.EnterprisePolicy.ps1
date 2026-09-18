# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = ($stig.RuleList | Select-Rule -Type FileContentRule).Where({ $PSItem.DscResource -eq 'Script' -and $PSItem.FilePath -eq 'distribution\policies.json' })

foreach ($rule in $rules)
{
    $encodedInstallDirectory = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($InstallDirectory))
    $encodedPolicy = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($rule.Value))

    Script (Get-ResourceTitle -Rule $rule)
    {
        SetScript = [scriptblock]::Create("& {
            `$installDirectory = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedInstallDirectory'))
            if (-not (Test-Path `$installDirectory))
            {
                return
            }

            `$path = Join-Path `$installDirectory 'distribution\policies.json'
            `$desired = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedPolicy')) | ConvertFrom-Json
            if (Test-Path `$path)
            {
                `$target = Get-Content `$path -Raw | ConvertFrom-Json -ErrorAction Stop
                if (-not `$target.PSObject.Properties['policies'])
                {
                    `$target | Add-Member NoteProperty policies ([pscustomobject]@{})
                }
            }
            else
            {
                `$directory = Split-Path `$path -Parent
                `$null = New-Item `$directory -ItemType Directory -Force
                `$target = [pscustomobject]@{policies = [pscustomobject]@{}}
            }

            function Merge-FirefoxPolicy(`$targetValue, `$desiredValue)
            {
                foreach (`$property in `$desiredValue.PSObject.Properties)
                {
                    `$existing = `$targetValue.PSObject.Properties[`$property.Name]
                    if (`$property.Value -is [pscustomobject] -and `$null -ne `$existing -and `$existing.Value -is [pscustomobject])
                    {
                        Merge-FirefoxPolicy `$existing.Value `$property.Value
                    }
                    else
                    {
                        `$targetValue | Add-Member NoteProperty `$property.Name `$property.Value -Force
                    }
                }
            }

            Merge-FirefoxPolicy `$target.policies `$desired
            `$json = `$target | ConvertTo-Json -Depth 20
            [IO.File]::WriteAllText(`$path, `$json, (New-Object Text.UTF8Encoding(`$false)))
        }")

        TestScript = [scriptblock]::Create("& {
            `$installDirectory = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedInstallDirectory'))
            if (-not (Test-Path `$installDirectory))
            {
                return `$true
            }

            `$path = Join-Path `$installDirectory 'distribution\policies.json'
            if (-not (Test-Path `$path))
            {
                return `$false
            }

            try
            {
                `$target = (Get-Content `$path -Raw | ConvertFrom-Json -ErrorAction Stop).policies
                `$desired = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedPolicy')) | ConvertFrom-Json -ErrorAction Stop
            }
            catch
            {
                return `$false
            }

            function Test-FirefoxPolicy(`$targetValue, `$desiredValue)
            {
                foreach (`$property in `$desiredValue.PSObject.Properties)
                {
                    `$existing = `$targetValue.PSObject.Properties[`$property.Name]
                    if (`$null -eq `$existing)
                    {
                        return `$false
                    }
                    if (`$property.Value -is [pscustomobject])
                    {
                        if (`$existing.Value -isnot [pscustomobject] -or -not (Test-FirefoxPolicy `$existing.Value `$property.Value))
                        {
                            return `$false
                        }
                    }
                    elseif ((`$existing.Value | ConvertTo-Json -Compress) -ne (`$property.Value | ConvertTo-Json -Compress))
                    {
                        return `$false
                    }
                }
                return `$true
            }

            return `$null -ne `$target -and (Test-FirefoxPolicy `$target `$desired)
        }")

        GetScript = [scriptblock]::Create("& {
            `$installDirectory = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedInstallDirectory'))
            if (-not (Test-Path `$installDirectory))
            {
                return @{Result = 'NotApplicable'}
            }

            `$path = Join-Path `$installDirectory 'distribution\policies.json'
            if (-not (Test-Path `$path))
            {
                return @{Result = 'Missing'}
            }
            return @{Result = (Get-Content `$path -Raw)}
        }")
    }
}