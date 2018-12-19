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

        Describe "SqlServer $($stig.TechnologyRole) $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)$($stig.TechnologyRole)_config" `
                        -SqlVersion $stig.TechnologyVersion `
                        -SqlRole $stig.TechnologyRole`
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'SqlScriptQuery' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.SqlScriptQueryRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[SqlScriptQuery\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing SqlScriptQuery $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.id.count) SqlScriptQueryRule settings" {
                    $hasAllSettings | Should -Be $true
                }
            }
        }

        Describe "SqlServer $($stig.TechnologyRole) $($stig.TechnologyVersion) $($stig.StigVersion) Single SkipRule/RuleType mof output" {

            $skipRule = Get-Random -InputObject $dscXml.DISASTIG.SqlScriptQueryRule.Rule.id
            $skipRuleType = "DocumentRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)$($stig.TechnologyRole)_config" `
                        -SqlVersion $stig.TechnologyVersion `
                        -SqlRole $stig.TechnologyRole`
                        -StigVersion $stig.StigVersion `
                        -SkipRule $skipRule `
                        -SkipRuleType $skipRuleType `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $dscXml = $dscXml.DISASTIG.DocumentRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $dscXml = $dscXml.count + $skipRule.count
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $dscXml Skipped settings" {
                    $dscMof.count | Should -Be $dscXml
                }
            }
        }

        Describe "SqlServer $($stig.TechnologyRole) $($stig.TechnologyVersion) $($stig.StigVersion) Multiple SkipRule/RuleType mof output" {

            $skipRule = Get-Random -InputObject $dscXml.DISASTIG.SqlScriptQueryRule.Rule.id -Count 2
            $skipRuleType = "DocumentRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)$($stig.TechnologyRole)_config" `
                        -SqlVersion $stig.TechnologyVersion `
                        -SqlRole $stig.TechnologyRole`
                        -StigVersion $stig.StigVersion `
                        -SkipRule $skipRule `
                        -SkipRuleType $skipRuleType `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $dscDocumentTypeRuleXml = $dscXml.DISASTIG.DocumentRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $expectedSkipRuleCount = $dscDocumentTypeRuleXml.count + $skipRule.count
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $expectedSkipRuleCount Skipped settings" {
                    $dscMof.count | Should -Be $expectedSkipRuleCount
                }
            }
        }

        Describe "SqlServer $($stig.TechnologyRole) $($stig.TechnologyVersion) $($stig.StigVersion) Exception mof output" {

            $exceptionRule = Get-Random -InputObject $dscXml.DISASTIG.SqlScriptQueryRule.rule
            $exception = $exceptionRule.id

            It "Should compile the MOF with STIG exception $exception without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)$($stig.TechnologyRole)_config" `
                        -SqlVersion $stig.TechnologyVersion `
                        -SqlRole $stig.TechnologyRole`
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
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
