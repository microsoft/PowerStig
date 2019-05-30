<#
    This file is dot sourced into every composite. It consolidates testing of exceptions,
    skipped rules, and organizational objects that were provided to the composite
#>
$title = "$($stig.Technology) $($stig.TechnologyVersion)"
if ($stig.TechnologyRole)
{
    $title = $title + " $($stig.TechnologyRole)"
}

Describe ($title + " $($stig.StigVersion) mof output") {

    $technologyConfig = "$($script:DSCCompositeResourceName)_config"

    $testParameterList = @{
        TechnologyVersion = $stig.TechnologyVersion
        TechnologyRole    = $stig.TechnologyRole
        StigVersion       = $stig.StigVersion
        OutputPath        = $TestDrive
    }

    # Add additional test parameters to current test configuration
    if($additionalTestParameterList)
    {
        $testParameterList += $additionalTestParameterList
    }

    It 'Should compile the MOF without throwing' {
        {& $technologyConfig @testParameterList} | Should -Not -Throw
    }

    $ruleNames = (Get-Member -InputObject $powerstigXml.DISASTIG |
            Where-Object -FilterScript {$_.Name -match '.*Rule' -and $_.Name -ne 'DocumentRule' -and $_.Name -ne 'ManualRule'}).Name

    $configurationDocumentPath = "$TestDrive\localhost.mof"
    $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

    foreach ($ruleName in $ruleNames)
    {
        Context $ruleName {
            $hasAllRules = $true
            $ruleList = @($powerstigXml.DISASTIG.$ruleName.Rule |
                    Where-Object {$PSItem.conversionstatus -eq 'pass' -and $PSItem.dscResource -ne 'ActiveDirectoryAuditRuleEntry' -and $PSItem.DuplicateOf -eq ''})

            $dscMof = $instances |
                Where-Object {$PSItem.ResourceID -match (Get-ResourceMatchStatement -RuleName $ruleName)}

            foreach ($rule in $ruleList)
            {
                <#
                    $dscMof is a collection of items, so the -not operator is used
                    in place of a -notmatch, since the -notmatch removes the
                    match from the collection.
                #>
                if (-not ($dscMof.ResourceID -match $rule.id))
                {
                    Write-Warning -Message "Missing $ruleName $($rule.id)"
                    $hasAllRules = $false
                }
            }

            foreach ($mofEntry in $dscMof)
            {
                if ($mofEntry.ResourceID -match "cAdministrativeTemplateSetting")
                {
                    It "Should not contain the Hive in Key Path for $($mofEntry.ResourceID)" {
                        $regexPattern = 'HKEY_CURRENT_USER|HKEY_CLASSES_ROOT|HKEY_LOCAL_MACHINE|HKEY_USERS|HKEY_CURRENT_CONFIG'
                        $regKeyResult = $mofEntry.KeyValueName | Select-String -Pattern $regexPattern -AllMatches
                        $regKeyResult.Matches.Count | Should -Be 0
                    }
                }
            }

            It "Should have $($ruleList.count) $ruleName settings" {
                $hasAllRules | Should -Be $true
            }
        }
    }

    <#
        Only run the detailed integration tests against one of the STIG
        files to verify that all functionality is working properly. If the
        functionality works for the first STIG is will work the same for
        remaining because the STIG class will have been tested.

        $stigList is recast as an array incase a single item is returned
    #>
    if (@($stigList).IndexOf($stig) -le '0')
    {
        Context 'Single Exception' {
            It "Should compile the MOF with STIG exception $exception without throwing" {
                {& $technologyConfig @testParameterList -Exception $exception} | Should -Not -Throw
            }
        }

        Context 'Multiple Exceptions' {
            It "Should compile the MOF with STIG exceptions $exceptionMultiple without throwing" {
                {& $technologyConfig @testParameterList -Exception $exceptionMultiple} | Should -Not -Throw
            }
        }

        Context 'Single Rule' {
            It 'Should compile the MOF without throwing' {
                {& $technologyConfig @testParameterList -SkipRule $skipRule } | Should -Not -Throw
            }

            # Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            $dscMof = @($instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"})

            It "Should have $($skipRule.count) Skipped settings" {
                $dscMof.count | Should -Be $skipRule.count
            }
        }

        Context 'Multiple Rules' {
            It 'Should compile the MOF without throwing' {
                {& $technologyConfig @testParameterList -SkipRule $skipRuleMultiple} | Should -Not -Throw
            }

            # Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            # Counts how many Skips there are and how many there should be.
            $expectedSkipRuleCount = $skipRuleMultiple.count
            $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}

            # This if/else is being used to output mof information from AppVeyor (Firefox 4.21 SkipRule test issue)
            if ($dscMof.Count -eq 0 -or $null -eq $dscMof.Count)
            {
                $instances.ResourceId | ForEach-Object -Process { try { Write-Warning "RId: $_" } catch { } }
            }
            else
            {
                $dscMof.ResourceId | ForEach-Object -Process { try { Write-Warning "RId: $_" } catch { } }
            }

            It "Should have $expectedSkipRuleCount Skipped settings" {
                $dscMof.count | Should -Be $expectedSkipRuleCount
            }
        }

        Context "$($stig.TechnologyRole) $($stig.StigVersion) Single Type" {
            It "Should compile the MOF without throwing" {
                {& $technologyConfig @testParameterList -SkipRuleType $skipRuleType} | Should -Not -Throw
            }
            # Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            # Counts how many Skips there are and how many there should be.
            $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}

            It "Should have $expectedSkipRuleTypeCount Skipped settings" {
                $dscMof.count | Should -Be $expectedSkipRuleTypeCount
            }
        }

        Context 'Multiple Types' {
            It "Should compile the MOF without throwing" {
                {& $technologyConfig @testParameterList -SkipruleType $skipRuleTypeMultiple} | Should -Not -Throw
            }
            # Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            # Counts how many Skips there are and how many there should be.
            $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}

            It "Should have $expectedSkipRuleTypeMultipleCount Skipped settings" {
                $dscMof.count | Should -Be $expectedSkipRuleTypeMultipleCount
            }
        }

        $stigPath = $stig.path.TrimEnd(".xml")
        $orgSettings = $stigPath + ".org.default.xml"

        It "Should compile the MOF with OrgSettings without throwing" {
            {& $technologyConfig @testParameterList -Orgsettings $orgSettings} | Should -Not -Throw
        }
    }
}
