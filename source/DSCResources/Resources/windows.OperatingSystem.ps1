# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type OperatingSystemRule

foreach ($rule in $rules)
{
    $resourceTitle = Get-ResourceTitle -Rule $rule
    $domainJoinedOnly = $rule.DomainJoinedOnly
    $requiredEdition = $rule.RequiredEdition.Replace("'", "''")
    $requiredArchitecture = $rule.RequiredArchitecture.Replace("'", "''")

    $scriptBlock = [scriptblock]::Create("
        Script '$resourceTitle'
        {
            GetScript =
            {
                `$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
                `$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
                return @{
                    Result = '`$(`$computerSystem.PartOfDomain);`$(`$operatingSystem.Caption);`$(`$operatingSystem.OSArchitecture)'
                }
            }

            TestScript =
            {
                `$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
                if ('$domainJoinedOnly' -eq 'True' -and -not `$computerSystem.PartOfDomain)
                {
                    return `$true
                }

                `$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
                `$editionMatches = `$operatingSystem.Caption -match [regex]::Escape('$requiredEdition')
                `$architectureMatches = `$operatingSystem.OSArchitecture -eq '$requiredArchitecture'
                return `$editionMatches -and `$architectureMatches
            }

            SetScript =
            {
            }
        }
    ")

    $scriptBlock.Invoke()
}