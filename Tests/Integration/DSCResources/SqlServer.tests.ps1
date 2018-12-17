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

        Describe "SqlServer $($Stig.TechnologyRole) $($Stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)$($Stig.TechnologyRole)_config" `
                        -SqlVersion $Stig.TechnologyVersion `
                        -SqlRole $Stig.TechnologyRole`
                        -StigVersion $Stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"
            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)

            Context 'SqlScriptQuery' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.SqlScriptQueryRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[SqlScriptQuery\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing SqlScriptQuery $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Id.Count) SqlScriptQueryRule settings" {
                    $HasAllSettings | Should -Be $true
                }
            }
        }

        Describe "SqlServer $($Stig.TechnologyRole) $($Stig.TechnologyVersion) $($Stig.StigVersion) Single SkipRule/RuleType mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.SqlScriptQueryRule.Rule.id
            $SkipRuleType = "DocumentRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)$($Stig.TechnologyRole)_config" `
                        -SqlVersion $Stig.TechnologyVersion `
                        -SqlRole $Stig.TechnologyRole`
                        -StigVersion $Stig.StigVersion `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            #region Gets the mof content
            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"
            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $DscXml = $DscXml.DISASTIG.DocumentRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $DscXml = $DscXml.Count + $SkipRule.Count
                $DscMof = $Instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $DscXml Skipped settings" {
                    $DscMof.Count | Should -Be $DscXml
                }
            }
        }

        Describe "SqlServer $($Stig.TechnologyRole) $($Stig.TechnologyVersion) $($Stig.StigVersion) Multiple SkipRule/RuleType mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.SqlScriptQueryRule.Rule.id -Count 2
            $SkipRuleType = "DocumentRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)$($Stig.TechnologyRole)_config" `
                        -SqlVersion $Stig.TechnologyVersion `
                        -SqlRole $Stig.TechnologyRole`
                        -StigVersion $Stig.StigVersion `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            #region Gets the mof content
            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"
            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $dscDocumentTypeRuleXml = $DscXml.DISASTIG.DocumentRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $ExpectedSkipRuleCount = $dscDocumentTypeRuleXml.Count + $SkipRule.Count
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $ExpectedSkipRuleCount Skipped settings" {
                    $DscMof.Count | Should -Be $ExpectedSkipRuleCount
                }
            }
        }

        Describe "SqlServer $($Stig.TechnologyRole) $($Stig.TechnologyVersion) $($Stig.StigVersion) Exception mof output" {

            $ExceptionRule = Get-Random -InputObject $DscXml.DISASTIG.SqlScriptQueryRule.rule
            $Exception = $ExceptionRule.ID

            It "Should compile the MOF with STIG exception $($Exception) without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)$($Stig.TechnologyRole)_config" `
                        -SqlVersion $Stig.TechnologyVersion `
                        -SqlRole $Stig.TechnologyRole`
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
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
