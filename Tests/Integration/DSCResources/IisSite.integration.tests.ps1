$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $ConfigFile

    $StigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    #region Test Setup
    $WebsiteName = @('WarioSite', 'DKSite')
    $WebAppPool = @('MushroomBeach', 'ToadHarbor')
    #endregionTest Setup

    #region Tests
    foreach ($Stig in $StigList)
    {
        [xml] $DscXml = Get-Content -Path $Stig.Path

        Describe "IIS Site $($Stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebAppPool $WebAppPool `
                        -WebsiteName $WebsiteName `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"

            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)

            Context 'IisLoggingRule' {
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebSite\]"}

                It "Should have $($WebsiteName.Count) xWebSite settings" {
                    $DscMof.Count | Should -Be $WebsiteName.Count
                }
            }

            Context 'WebConfigurationPropertyRule' {

                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebConfigProperty\]"}

                foreach ($Website in $WebsiteName)
                {
                    foreach ($Setting in $DscXml)
                    {
                        if (-not ($DscMof.ResourceID -match $Setting.Id))
                        {
                            Write-Warning -Message "$Website missing WebConfigurationPropertyRule Setting $($Setting.Id)"
                            $HasAllSettings = $false
                        }
                    }
                }

                It "Should have $($DscXml.Count) WebConfigurationPropertyRule settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'WebAppPoolRule' {
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebAppPool\]"}

                It "Should have $($WebsiteName.Count) xWebAppPool settings" {
                    $DscMof.Count | Should -Be $WebAppPool.Count
                }
            }

            Context 'MimeTypeRule' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.MimeTypeRule.Rule
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xIisMimeTypeMapping\]"}

                foreach ($Website in $WebsiteName)
                {
                    foreach ($Setting in $DscXml)
                    {
                        if (-not ($DscMof.ResourceID -match $Setting.Id))
                        {
                            Write-Warning -Message "$Website ,missing MimeTypeRule Setting $($Setting.Id)"
                            $HasAllSettings = $false
                        }
                    }
                }

                It "Should have $($DscXml.Count) WebConfigurationPropertyRule settings" {
                    $HasAllSettings | Should -Be $true
                }
            }
        }

        Describe "IIS Site $($Stig.StigVersion) Single SkipRule/RuleType mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id
            $SkipRuleType = "IisLoggingRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebAppPool $WebAppPool `
                        -WebsiteName $WebsiteName `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -OutputPath $TestDrive `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType `
                } | Should -Not -Throw
            }

            #region Gets the mof content
            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"
            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $DscIisLoggingRuleXml = $DscXml.DISASTIG.IisLoggingRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq 'pass'}
                $ExpectedSkipRuleCount = ($($DscIisLoggingRuleXml.Count) + $($SkipRule.Count))
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $ExpectedSkipRuleCount Skipped settings" {
                    $DscMof.Count | Should -Be $ExpectedSkipRuleCount
                }
            }
        }

        Describe "IIS Site $($Stig.StigVersion) Multiple SkipRule/RuleType mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.MimeTypeRule.Rule.id -Count 2
            $SkipRuleType = @('WebAppPoolRule','IisLoggingRule')

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebsiteName $WebsiteName `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -OutputPath $TestDrive `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType `
                } | Should -Not -Throw
            }

            #region Gets the mof content
            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"
            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $DscWebAppPoolRuleXml = $DscXml.DISASTIG.WebAppPoolRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "Pass"}
                $DscIisLoggingRuleXml = $DscXml.DISASTIG.IisLoggingRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "Pass"}
                $ExpectedSkipRuleCount = ($($DscWebAppPoolRuleXml.Count) + $($DscIisLoggingRuleXml.Count) + $($SkipRule.Count))
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $ExpectedSkipRuleCount Skipped settings" {
                    $DscMof.Count | Should -Be $ExpectedSkipRuleCount
                }
            }
        }

        Describe "IIS Site $($Stig.StigVersion) Exception mof output" {

                $ExceptionRule = Get-Random -InputObject $DscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $Exception = $ExceptionRule.ID

            It "Should compile the MOF with STIG exception $($Exception) without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebsiteName $WebsiteName `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -OutputPath $TestDrive `
                        -Exception $Exception
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
