<#
    This file is dot sourced into every composite. It consolidates testing of exceptions,
    skipped rules, and organizational objects that were provided to the composite
#>

Describe "$($stig.TechnologyRole) $($stig.StigVersion) Exception" {

    Context 'Single Exception' {

        #$exception = Get-Random -InputObject $matchedRuleType.Rule.id

        It "Should compile the MOF with STIG exception $exception without throwing" {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole`
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -Exception $exception
            } | Should -Not -Throw
        }
    }
    Context 'Multiple Exceptions' {

        #$exceptionMulti = Get-Random -InputObject $matchedRuleType.Rule.id -count 2
#need to fix multiple exception passing
        It "Should compile the MOF with STIG exceptions $exceptionMultiple without throwing" {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole`
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -Exception $exceptionMultiple
            } | Should -Not -Throw
        }
    }
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) SkipRule" {

    Context 'Single Rule' {

        #$skipRule = Get-Random -InputObject $matchedRuleType.Rule.id

        It 'Should compile the MOF without throwing' {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -SkipRule $skipRule `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole `
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -OutputPath $TestDrive
            } | Should -Not -Throw
        }

        #region Gets the mof content
        $configurationDocumentPath = "$TestDrive\localhost.mof"
        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
        #endregion

        #region counts how many Skips there are and how many there should be.
        $dscXml = $skipRule.count
        $dscMof = @($instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"})
        #endregion

        It "Should have $dscXml Skipped settings" {
            $dscMof.count | Should -Be $dscXml
        }
        
    }

    Context 'Multiple Rules' {

        #$skipRule = Get-Random -InputObject $matchedRuleType.Rule.id -Count 2

        It 'Should compile the MOF without throwing' {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -SkipRule $skipRuleMultiple `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole `
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -OutputPath $TestDrive
            } | Should -Not -Throw
        }

        #region Gets the mof content
        $configurationDocumentPath = "$TestDrive\localhost.mof"
        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
        #endregion

        #region counts how many Skips there are and how many there should be.
        $expectedSkipRuleCount = $skipRuleMultiple.count
        $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
        #endregion

        It "Should have $expectedSkipRuleCount Skipped settings" {
            $dscMof.count | Should -Be $expectedSkipRuleCount
        }

    }
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) SkipRuleType" {
    Context 'Single Type' {
        It "Should compile the MOF without throwing" {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole `
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -SkipruleType $skipRuleType 
            } | Should -Not -Throw
        }
        #region Gets the mof content
        $configurationDocumentPath = "$TestDrive\localhost.mof"
        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
        #endregion

        #region counts how many Skips there are and how many there should be.
        $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
        #endregion

        It "Should have $expectedSkipRuleTypeCount Skipped settings" {
            $dscMof.count | Should -Be $expectedSkipRuleTypeCount
        }
    }
    Context 'Multiple Types' {
        It "Should compile the MOF without throwing" {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole `
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -SkipruleType $skipRuleTypeMultiple 
            } | Should -Not -Throw
        }
        #region Gets the mof content
        $configurationDocumentPath = "$TestDrive\localhost.mof"
        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
        #endregion

        #region counts how many Skips there are and how many there should be.
        $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
        #endregion

        It "Should have $expectedSkipRuleTypeMultipleCount Skipped settings" {
            $dscMof.count | Should -Be $expectedSkipRuleTypeMultipleCount
        }
    }
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) OrgSettings" {

    $stigPath = $stig.path.TrimEnd(".xml")
    $orgSettings = $stigPath + ".org.default.xml"

    It "Should compile the MOF with OrgSettings without throwing" {
        {
            & $technologyConfig `
                -BrowserVersion $stig.TechnologyRole `
                -StigVersion $stig.StigVersion `
                -OutputPath $TestDrive `
                -OfficeApp $stig.TechnologyRole `
                -ConfigPath $configPath `
                -PropertiesPath $propertiesPath `
                -OsVersion $stig.TechnologyVersion `
                -ForestName 'integration.test' `
                -DomainName 'integration.test' `
                -OsRole $stig.TechnologyRole `
                -SqlVersion $stig.TechnologyVersion `
                -SqlRole $stig.TechnologyRole`
                -WebAppPool $WebAppPool `
                -WebsiteName $WebsiteName `
                -LogPath $TestDrive `
                -Orgsettings $orgSettings
        } | Should -Not -Throw
    }
}


