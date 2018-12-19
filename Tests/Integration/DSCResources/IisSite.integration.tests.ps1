$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $configFile

    $stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    #region Test Setup
    $WebsiteName = @('WarioSite', 'DKSite')
    $WebAppPool = @('MushroomBeach', 'ToadHarbor')
    #endregionTest Setup

    #region Tests
    foreach ($stig in $stigList)
    {
        [xml] $dscXml = Get-Content -Path $stig.Path

        Describe "IIS Site $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebAppPool $WebAppPool `
                        -WebsiteName $WebsiteName `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'IisLoggingRule' {
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebSite\]"}

                It "Should have $($WebsiteName.count) xWebSite settings" {
                    $dscMof.count | Should -Be $WebsiteName.count
                }
            }

            Context 'WebConfigurationPropertyRule' {

                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebConfigProperty\]"}

                foreach ($Website in $WebsiteName)
                {
                    foreach ($setting in $dscXml)
                    {
                        if (-not ($dscMof.ResourceID -match $setting.id))
                        {
                            Write-Warning -Message "$Website missing WebConfigurationPropertyRule Setting $($setting.id)"
                            $hasAllSettings = $false
                        }
                    }
                }

                It "Should have $($dscXml.count) WebConfigurationPropertyRule settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'WebAppPoolRule' {
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebAppPool\]"}

                It "Should have $($WebsiteName.count) xWebAppPool settings" {
                    $dscMof.count | Should -Be $WebAppPool.count
                }
            }

            Context 'MimeTypeRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.MimeTypeRule.Rule
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xIisMimeTypeMapping\]"}

                foreach ($Website in $WebsiteName)
                {
                    foreach ($setting in $dscXml)
                    {
                        if (-not ($dscMof.ResourceID -match $setting.id))
                        {
                            Write-Warning -Message "$Website ,missing MimeTypeRule Setting $($setting.id)"
                            $hasAllSettings = $false
                        }
                    }
                }

                It "Should have $($dscXml.count) WebConfigurationPropertyRule settings" {
                    $hasAllSettings | Should -Be $true
                }
            }
        }

        Describe "IIS Site $($stig.StigVersion) Single SkipRule/RuleType mof output" {

            $skipRule = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id
            $skipRuleType = "IisLoggingRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebAppPool $WebAppPool `
                        -WebsiteName $WebsiteName `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive `
                        -SkipRule $skipRule `
                        -SkipRuleType $skipRuleType `
                } | Should -Not -Throw
            }

            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $dscIisLoggingRuleXml = $dscXml.DISASTIG.IisLoggingRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq 'pass'}
                $expectedSkipRuleCount = ($($dscIisLoggingRuleXml.count) + $($skipRule.count))
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $expectedSkipRuleCount Skipped settings" {
                    $dscMof.count | Should -Be $expectedSkipRuleCount
                }
            }
        }

        Describe "IIS Site $($stig.StigVersion) Multiple SkipRule/RuleType mof output" {

            $skipRule = Get-Random -InputObject $dscXml.DISASTIG.MimeTypeRule.Rule.id -Count 2
            $skipRuleType = @('WebAppPoolRule','IisLoggingRule')

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebsiteName $WebsiteName `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive `
                        -SkipRule $skipRule `
                        -SkipRuleType $skipRuleType `
                } | Should -Not -Throw
            }

            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $dscWebAppPoolRuleXml = $dscXml.DISASTIG.WebAppPoolRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "Pass"}
                $dscIisLoggingRuleXml = $dscXml.DISASTIG.IisLoggingRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "Pass"}
                $expectedSkipRuleCount = ($($dscWebAppPoolRuleXml.count) + $($dscIisLoggingRuleXml.count) + $($skipRule.count))
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $expectedSkipRuleCount Skipped settings" {
                    $dscMof.count | Should -Be $expectedSkipRuleCount
                }
            }
        }

        Describe "IIS Site $($stig.StigVersion) Exception mof output" {

                $exceptionRule = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $exception = $exceptionRule.id

            It "Should compile the MOF with STIG exception $exception without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebsiteName $WebsiteName `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive `
                        -Exception $exception
                } | Should -Not -Throw
            }
        }
    }
    #endregion Tests
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
