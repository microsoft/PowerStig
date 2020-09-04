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
        TechnologyVersion  = $stig.TechnologyVersion
        TechnologyRole     = $stig.TechnologyRole
        StigVersion        = $stig.StigVersion
        OutputPath         = $TestDrive
        ResourceParameters = $resourceParameters
    }

    # Add additional test parameters to current test configuration
    if ($additionalTestParameterList)
    {
        $testParameterList += $additionalTestParameterList
    }

    It 'Should compile the MOF without throwing' {
        {& $technologyConfig @testParameterList} | Should -Not -Throw
    }

    $ruleNames = (Get-Member -InputObject $powerstigXml |
        Where-Object -FilterScript {$_.Name -match '.*Rule' -and $_.Name -ne 'DocumentRule' -and $_.Name -ne 'ManualRule'}).Name

    $configurationDocumentPath = "$TestDrive\localhost.mof"
    $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

    foreach ($ruleName in $ruleNames)
    {
        Context $ruleName {
            $hasAllRules = $true
            $ruleList = @($powerstigXml.$ruleName.Rule |
                Where-Object -FilterScript {$PSItem.conversionstatus -eq 'pass' -and $PSItem.dscResource -ne 'ActiveDirectoryAuditRuleEntry' -and $PSItem.DuplicateOf -eq ''})

            $dscMof = $instances |
                Where-Object -FilterScript {$PSItem.ResourceID -match (Get-ResourceMatchStatement -RuleName $ruleName)}

            foreach ($rule in $ruleList)
            {
                <#
                    $dscMof is a collection of items, so the -not operator is used
                    in place of a -notmatch, since the -notmatch removes the
                    match from the collection.
                #>
                if (-not ($dscMof.ResourceID -match '\[Skip\]' -or $dscMof.ResourceID -match $rule.id))
                {
                    Write-Warning -Message "Missing $ruleName $($rule.id)"
                    $hasAllRules = $false
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
            It "Should compile the MOF with STIG exception $($exception.Keys) without throwing" {
                {& $technologyConfig @testParameterList -Exception $exception} | Should -Not -Throw
            }
        }

        Context 'Multiple Exceptions' {
            It "Should compile the MOF with STIG exceptions $($exceptionMultiple.Keys) without throwing" {
                {& $technologyConfig @testParameterList -Exception $exceptionMultiple} | Should -Not -Throw
            }
        }

        Context 'Single Backward Compatibility Exception' {
            It "Should compile the MOF with STIG exception $($backCompatException.Keys) without throwing" {
                {& $technologyConfig @testParameterList -Exception $backCompatException} | Should -Not -Throw
            }
        }

        Context 'Multiple Backward Compatibility Exceptions' {
            It "Should compile the MOF with STIG exceptions $($backCompatExceptionMultiple.Keys) without throwing" {
                {& $technologyConfig @testParameterList -Exception $backCompatExceptionMultiple} | Should -Not -Throw
            }
        }

        Context 'Single Skip Rule' {
            It 'Should compile the MOF without throwing' {
                {& $technologyConfig @testParameterList -SkipRule $skipRule } | Should -Not -Throw
            }

            # Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            $dscMof = @($instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"})

            It "Should have $($skipRule.count + $blankSkipRuleId.Count) Skipped settings" {
                $dscMof.count | Should -Be ($skipRule.count + $blankSkipRuleId.Count)
            }
        }

        Context 'Multiple Skip Rules' {
            It 'Should compile the MOF without throwing' {
                {& $technologyConfig @testParameterList -SkipRule $skipRuleMultiple} | Should -Not -Throw
            }

            # Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            # Counts how many Skips there are and how many there should be.
            $expectedSkipRuleCount = $skipRuleMultiple.count + $blankSkipRuleId.Count
            $dscMof = @($instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"})

            It "Should have $expectedSkipRuleCount Skipped settings" {
                $dscMof.count | Should -Be $expectedSkipRuleCount
            }
        }

        Context "$($stig.TechnologyRole) $($stig.StigVersion) Single Skip Rule Type" {
            It "Should compile the MOF without throwing" {
                {& $technologyConfig @testParameterList -SkipRuleType $skipRuleType} | Should -Not -Throw
            }
            # Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            # Counts how many Skips there are and how many there should be.
            $dscMof = @($instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"})

            It "Should have $expectedSkipRuleTypeCount Skipped settings" {
                $dscMof.count | Should -Be $expectedSkipRuleTypeCount
            }
        }

        Context "$($stig.TechnologyRole) $($stig.StigVersion) Multiple Skip Rule Types" {
            It "Should compile the MOF without throwing" {
                {& $technologyConfig @testParameterList -SkipruleType $skipRuleTypeMultiple} | Should -Not -Throw
            }
            # Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            # Counts how many Skips there are and how many there should be.
            $dscMof = @($instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"})

            It "Should have $expectedSkipRuleTypeMultipleCount Skipped settings" {
                $dscMof.Count | Should -Be $expectedSkipRuleTypeMultipleCount
            }
        }

        Context "$($stig.TechnologyRole) $($stig.StigVersion) Single Skip Rule Category" {
            It "Should compile the MOF without throwing" {
                {& $technologyConfig @testParameterList -SkipruleType $skipRuleTypeMultiple} | Should -Not -Throw
            }
            # Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            # Counts how many Skips there are and how many there should be.
            $dscMof = @($instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"})

            It "Should have $expectedSkipRuleTypeMultipleCount Skipped settings" {
                $dscMof.Count | Should -Be $expectedSkipRuleTypeMultipleCount
            }
        }

        Context 'OrgSettings' {
            $stigPath = $stig.path.TrimEnd(".xml")
            $orgSettings = $stigPath + ".org.default.xml"

            It 'Should compile the MOF with Xml File OrgSettings without throwing' {
                {& $technologyConfig @testParameterList -Orgsettings $orgSettings} | Should -Not -Throw
            }

            [xml]$xmlOrgSetting = Get-Content -Path $orgSettings
            :orgSettingForeach foreach ($ruleIdOrgSetting in $xmlOrgSetting.OrganizationalSettings.OrganizationalSetting)
            {
                $properties = $ruleIdOrgSetting.Attributes.Name | Where-Object -FilterScript {$PSItem -ne 'id'}
                foreach ($property in $properties)
                {
                    $ruleIdPropertyValue = $ruleIdOrgSetting.$Property
                    if ([string]::IsNullOrEmpty($ruleIdPropertyValue) -eq $false)
                    {
                        $orgSettingHashtable = @{
                            $ruleIdOrgSetting.id = @{
                                $property = $ruleIdPropertyValue
                            }
                        }
                        break orgSettingForeach
                    }
                }
            }

            if ($orgSettingHashtable -is [hashtable])
            {
                It 'Should compile the MOF with hashtable OrgSettings without throwing' {
                    {& $technologyConfig @testParameterList -OrgSettings $orgSettingHashtable} | Should -Not -Throw
                }
            }
        }
    }
}
