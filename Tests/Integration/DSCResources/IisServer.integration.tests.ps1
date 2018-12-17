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

    #region Integration Tests
    foreach ($Stig in $StigList)
    {
        [xml] $DscXml = Get-Content -Path $Stig.Path

        Describe "IIS Server $($Stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -LogPath $TestDrive `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"

            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)

            Context 'IisLoggingRule' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.IisLoggingRule.Rule
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xIisLogging\]"}

                foreach ($Setting in $DscXml)
                {
                    if (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "WebServer missing IisLoggingRule Setting $($Setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) IisLoggingRule settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'WebConfigurationPropertyRule' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebConfigProperty\]"}

                foreach ($Setting in $DscXml)
                {
                    if (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "WebServer missing WebConfigurationPropertyRule Setting $($Setting.Id)"
                        $HasAllSettings = $false
                    }
                }


                It "Should have $($DscXml.Count) WebConfigurationPropertyRule settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'MimeTypeRule' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.MimeTypeRule.Rule
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xIisMimeTypeMapping\]"}

                foreach ($Setting in $DscXml)
                {
                    if (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "WebServer missing MimeTypeRule Setting $($Setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) MimeTypeRule settings" {
                    $HasAllSettings | Should -Be $true
                }
            }
        }

        Describe "IIS Server $($Stig.StigVersion) Single SkipRule/RuleType mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.MimeTypeRule.Rule.id
            $SkipRuleType = "IisLoggingRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -LogPath $TestDrive `
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
                $DscIisLoggingRuleXml = $DscXml.DISASTIG.IisLoggingRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "pass"}
                $ExpectedSkipRuleCount = ($($DscIisLoggingRuleXml.Count) + $($SkipRule.Count))
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion
                It "Should have $ExpectedSkipRuleCount Skipped settings" {
                    $DscMof.Count | Should -Be $ExpectedSkipRuleCount
                }
            }
        }

        Describe "IIS Server $($Stig.StigVersion) Multiple SkipRule/RuleType mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id -Count 2
            $SkipRuleType = @('MimeTypeRule','IisLoggingRule')

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -LogPath $TestDrive `
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
                $DscMimeTypeRuleXml = $DscXml.DISASTIG.MimeTypeRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "Pass"}
                $DscIisLoggingRuleXml = $DscXml.DISASTIG.IisLoggingRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "Pass"}
                $ExpectedSkipRuleCount = ($($DscMimeTypeRuleXml.Count) + $($DscIisLoggingRuleXml.Count) + $($SkipRule.Count))
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $ExpectedSkipRuleCount Skipped settings" {
                    $DscMof.Count | Should -Be $ExpectedSkipRuleCount
                }
            }
        }

        Describe "IIS Server $($Stig.StigVersion) Exception mof output" {

            $ExceptionRule = Get-Random -InputObject $DscXml.DISASTIG.WebConfigurationPropertyRule.Rule
            $Exception = $ExceptionRule.ID

            It "Should compile the MOF with STIG exception $($Exception) without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -LogPath $TestDrive `
                        -OutputPath $TestDrive `
                        -Exception $Exception
                } | Should -Not -Throw
            }
        }
    }
}
#endregion Tests
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
