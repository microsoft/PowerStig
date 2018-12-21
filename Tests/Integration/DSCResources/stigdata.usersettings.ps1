<#
    This file is dot sourced into every composite. It consolidates testing of exceptions,
    skipped rules, and organizational objects that were provided to the composite
#>

if($dscXml.DISASTIG.ChildNodes.ToString() -match "RegistryRule")
{
    $matchedRuleType = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule
}

if($dscXml.DISASTIG.ChildNodes.ToString() -match "FileContentRule")
{
    $matchedRuleType = Get-Random -InputObject $dscXml.DISASTIG.FileContentRule
}

if($dscXml.DISASTIG.ChildNodes.ToString() -match "SqlScriptQueryRule")
{
    $matchedRuleType = $dscXml.DISASTIG.SqlScriptQueryRule
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) Exception" {

    Context 'Single Exception' {

        $exception = Get-Random -InputObject $matchedRuleType.Rule.id

        It "Should compile the MOF with STIG exception $exception without throwing" {
            {
                & "$($script:DSCCompositeResourceName)_config" `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -Exception $exception `
            } | Should -Not -Throw
        }
    }
    Context 'Multiple Exceptions' {

        $exception = Get-Random -InputObject $matchedRuleType.Rule.id -count 2
#need to fix multiple exception passing
        It "Should compile the MOF with STIG exception $exception without throwing" {
            {
                & "$($script:DSCCompositeResourceName)_config" `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -Exception $exception
            } | Should -Not -Throw
        }
    }
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) SkipRule" {

    Context 'Single Rule' {

        $skipRule = Get-Random -InputObject $matchedRuleType.Rule.id

        It 'Should compile the MOF without throwing' {
            {
                & "$($script:DSCCompositeResourceName)_config" `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -SkipRule $skipRule `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
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

        $skipRule = Get-Random -InputObject $matchedRuleType.Rule.id -Count 2

        It 'Should compile the MOF without throwing' {
            {
                & "$($script:DSCCompositeResourceName)_config" `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -SkipRule $skipRule `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OutputPath $TestDrive
            } | Should -Not -Throw
        }

        #region Gets the mof content
        $configurationDocumentPath = "$TestDrive\localhost.mof"
        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
        #endregion

        #region counts how many Skips there are and how many there should be.
        $expectedSkipRuleCount = $skipRule.count
        $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
        #endregion

        It "Should have $expectedSkipRuleCount Skipped settings" {
            $dscMof.count | Should -Be $expectedSkipRuleCount
        }

    }
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) SkipRuleType" {
    Context 'Single Type' {
    }
    Context 'Multiple Types' {
    }
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) OrgSettings" {

    $stigPath = $stig.path.TrimEnd(".xml")
    $orgSettings = $stigPath + ".org.default.xml"

    It "Should compile the MOF with OrgSettings without throwing" {
        {
            & "$($script:DSCCompositeResourceName)_config" `
                -BrowserVersion $stig.TechnologyRole `
                -StigVersion $stig.StigVersion `
                -OutputPath $TestDrive `
                -OfficeApp $stig.TechnologyRole `
                -ConfigPath $configPath `
                -PropertiesPath $propertiesPath `
                -Orgsettings $orgSettings
        } | Should -Not -Throw
    }
}


