$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $ConfigFile

    $stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    #region Test Setup
    $websiteName = @('WarioSite', 'DKSite')
    $webAppPool = @('MushroomBeach', 'ToadHarbor')
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
                        -WebsiteName $websiteName `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'IisLoggingRule' {
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebSite\]"}

                It "Should have $($websiteName.count) xWebSite settings" {
                    $dscMof.count | Should Be $websiteName.count
                }
            }

            Context 'WebConfigurationPropertyRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebConfigProperty\]"}

                foreach ($website in $websiteName)
                {
                    foreach ($setting in $dscXml)
                    {
                        if (-not ($dscMof.ResourceID -match $setting.Id))
                        {
                            Write-Warning -Message "$website missing WebConfigurationPropertyRule Setting $($setting.Id)"
                            $hasAllSettings = $false
                        }
                    }
                }

                It "Should have $($dscXml.Count) WebConfigurationPropertyRule settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'WebAppPoolRule' {
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebAppPool\]"}

                It "Should have $($websiteName.count) xWebAppPool settings" {
                    $dscMof.count | Should Be $webAppPool.count
                }
            }

            Context 'MimeTypeRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.MimeTypeRule.Rule
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xIisMimeTypeMapping\]"}

                foreach ($website in $websiteName)
                {
                    foreach ($setting in $dscXml)
                    {
                        if (-not ($dscMof.ResourceID -match $setting.Id))
                        {
                            Write-Warning -Message "$website ,missing MimeTypeRule Setting $($setting.Id)"
                            $hasAllSettings = $false
                        }
                    }
                }

                It "Should have $($dscXml.Count) WebConfigurationPropertyRule settings" {
                    $hasAllSettings | Should Be $true
                }
            }
        }
        Describe "IIS Site $($stig.StigVersion) Single SkipRule/RuleType mof output" {
            
            $SkipRule = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id
            $SkipRuleType = "IisLoggingRule"
            
            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebAppPool $WebAppPool `
                        -WebsiteName $websiteName `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType `
                } | Should not throw
            }
            
            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion
            
            Context 'Skip check' {
                
                #region counts how many Skips there are and how many there should be.
                $dscIisLoggingRuleXml = $dscXml.DISASTIG.IisLoggingRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "pass"}
                $expectedSkipRuleCount = ($($dscIisLoggingRuleXml.Count) + $($SkipRule.Count))
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion
                
                It "Should have $expectedSkipRuleCount Skipped settings" {
                    $dscMof.count | Should Be $expectedSkipRuleCount
                }
            }
        }
        Describe "IIS Site $($stig.StigVersion) Multiple SkipRule/RuleType mof output" {
            
            $SkipRule = Get-Random -InputObject $dscXml.DISASTIG.MimeTypeRule.Rule.id -Count 2
            $SkipRuleType = @('WebAppPoolRule','IisLoggingRule')
            
            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebsiteName $websiteName `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType `
                } | Should not throw
            }
            
            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion
            
            Context 'Skip check' {
                
                #region counts how many Skips there are and how many there should be.
                $dscWebAppPoolRuleXml = $dscXml.DISASTIG.WebAppPoolRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "Pass"}
                $dscIisLoggingRuleXml = $dscXml.DISASTIG.IisLoggingRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "Pass"}
                $expectedSkipRuleCount = ($($dscWebAppPoolRuleXml.Count) + $($dscIisLoggingRuleXml.count) + $($SkipRule.Count))
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion
                
                It "Should have $expectedSkipRuleCount Skipped settings" {
                    $dscMof.count | Should Be $expectedSkipRuleCount
                }
            }
        }

        Describe "IIS Site $($stig.StigVersion) Exception mof output"{
            
            If (-not $ExceptionRuleValueData)
            {   
                $ExceptionRule = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $Exception = $ExceptionRule.ID
                $ExceptionRuleValueData = $ExceptionRule.Value
            }

            It "Should compile the MOF with STIG exception $($Exception) without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebsiteName $websiteName `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive `
                        -Exception $Exception
                } | Should not throw
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
