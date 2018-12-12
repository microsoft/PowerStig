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

    #region Integration Tests
    foreach ($stig in $stigList)
    {
        [xml] $dscXml = Get-Content -Path $stig.Path
        
        Describe "IIS Server $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -LogPath $TestDrive `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'IisLoggingRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.IisLoggingRule.Rule
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[xIisLogging\]"}

                foreach ($setting in $dscXml)
                {
                    if (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "WebServer missing IisLoggingRule Setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) IisLoggingRule settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'WebConfigurationPropertyRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[xWebConfigProperty\]"}

                foreach ($setting in $dscXml)
                {
                    if (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "WebServer missing WebConfigurationPropertyRule Setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }


                It "Should have $($dscXml.Count) WebConfigurationPropertyRule settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'MimeTypeRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.MimeTypeRule.Rule
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[xIisMimeTypeMapping\]"}

                foreach ($setting in $dscXml)
                {
                    if (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "WebServer missing MimeTypeRule Setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) MimeTypeRule settings" {
                    $hasAllSettings | Should Be $true
                }
            }
        }

        Describe "IIS Server $($stig.StigVersion) Single SkipRule/RuleType mof output" {
            
            $SkipRule = Get-Random -InputObject $dscXml.DISASTIG.MimeTypeRule.Rule.id
            $SkipRuleType = "IisLoggingRule"
            
            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -LogPath $TestDrive `
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
        
        Describe "IIS Server $($stig.StigVersion) Multiple SkipRule/RuleType mof output" {
            
            $SkipRule = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id -Count 2
            $SkipRuleType = @('MimeTypeRule','IisLoggingRule')
           
            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -LogPath $TestDrive `
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
                $dscMimeTypeRuleXml = $dscXml.DISASTIG.MimeTypeRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "Pass"}
                $dscIisLoggingRuleXml = $dscXml.DISASTIG.IisLoggingRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "Pass"}
                $expectedSkipRuleCount = ($($dscMimeTypeRuleXml.Count) + $($dscIisLoggingRuleXml.count) + $($SkipRule.Count))
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion
                
                It "Should have $expectedSkipRuleCount Skipped settings" {
                    $dscMof.count | Should Be $expectedSkipRuleCount
                }
            }
        }
    }
}
#endregion Tests
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
