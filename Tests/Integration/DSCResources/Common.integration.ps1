<#
    This file is dot sourced into every composite. It consolidates testing of exceptions,
    skipped rules, and organizational objects that were provided to the composite
#>
Describe "$($stig.Technology) $($stig.TechnologyVersion) $($stig.TechnologyRole) $($stig.StigVersion) mof output" {

    $technologyConfig = "$($script:DSCCompositeResourceName)_config"

    $testhash = @{
        StigVersion     = $stig.StigVersion
        BrowserVersion  = $stig.TechnologyVersion
        OfficeApp       = $stig.TechnologyVersion
        OsVersion       = $stig.TechnologyVersion
        SqlVersion      = $stig.TechnologyVersion
        OsRole          = $stig.TechnologyRole
        SqlRole         = $stig.TechnologyRole
        ForestName      = 'integration.test'
        DomainName      = 'integration.test'
        Exception       = $exception
        ConfigPath      = $configPath
        OutputPath      = $TestDrive
        PropertiesPath  = $propertiesPath
        WebAppPool      = $WebAppPool
        WebsiteName     = $WebsiteName
        LogPath         = $TestDrive
    }

    It 'Should compile the MOF without throwing' {
        {& $technologyConfig @testhash} | Should -Not -Throw
    }

    <#{TODO}#> #Add back modified version after migration
    $configurationDocumentPath = "$TestDrive\localhost.mof"
    $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

    $ruleNames = (Get-Member -InputObject $powerstigXml.DISASTIG |
        Where-Object -FilterScript {$_.Name -match '.*Rule' -and $_.Name -ne 'DocumentRule' -and $_.Name -ne 'ManualRule'}).Name

    foreach ($ruleName in $ruleNames)
    {
        Context $ruleName {
            $hasAllRules = $true
            $ruleList = @($powerstigXml.DISASTIG.$ruleName.Rule) |
                Where-Object {$PSItem.conversionstatus -eq 'pass' -and $PSItem.dscResource -ne 'ActiveDirectoryAuditRuleEntry'}

            $instanceFilter = Get-ResourceMatchStatement -RuleName $ruleName
            $dscMof = $instances |
                Where-Object {$PSItem.ResourceID -match $instanceFilter}

            foreach ($rule in $ruleList)
            {
                <#
                    $dscMof is a collection of items, so the -not operator is used
                    in place of a -not match, since the -notmatch simply removes
                    the match from te collection.
                #>
                if (-not ($dscMof.ResourceID -match $rule.id))
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

    Context 'Single Exception' {
        It "Should compile the MOF with STIG exception $exception without throwing" {
            {& $technologyConfig @testhash} | Should -Not -Throw
        }
    }

    Context 'Multiple Exceptions' {
        $testhash.exception = $exceptionMultiple
        It "Should compile the MOF with STIG exceptions $exceptionMultiple without throwing" {
            {& $technologyConfig @testhash} | Should -Not -Throw
        }
    }

    Context 'Single Rule' {
        It 'Should compile the MOF without throwing' {
            {& $technologyConfig @testhash -SkipRule $skipRule } | Should -Not -Throw
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
            {& $technologyConfig @testhash -SkipRule $skipRuleMultiple} | Should -Not -Throw
        }

        # Gets the mof content
        $configurationDocumentPath = "$TestDrive\localhost.mof"
        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

        # Counts how many Skips there are and how many there should be.
        $expectedSkipRuleCount = $skipRuleMultiple.count
        $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}

        It "Should have $expectedSkipRuleCount Skipped settings" {
            $dscMof.count | Should -Be $expectedSkipRuleCount
        }
    }

    Context "$($stig.TechnologyRole) $($stig.StigVersion) Single Type" {
        It "Should compile the MOF without throwing" {
            {& $technologyConfig @testhash -SkipRuleType $skipRuleType} | Should -Not -Throw
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
            {& $technologyConfig @testhash -SkipruleType $skipRuleTypeMultiple} | Should -Not -Throw
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
        {& $technologyConfig @testhash -Orgsettings $orgSettings} | Should -Not -Throw
    }
}
