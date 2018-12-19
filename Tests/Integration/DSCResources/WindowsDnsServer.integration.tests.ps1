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

        Describe "Windows DNS $($stig.TechnologyVersion) $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'Registry' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.RegistryRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[xRegistry\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing registry Setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) Registry settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Services' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.ServiceRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[xService\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing service setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) service settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'AccountPolicy' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.AccountPolicyRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[AccountPolicy\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing security setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) security settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'UserRightsAssignment' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.UserRightRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[UserRightsAssignment\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing user right $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) user rights settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'SecurityOption' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.SecurityOptionRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[SecurityOption\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing security setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) security settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Windows Feature' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WindowsFeatureRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[WindowsFeature\]"}

                foreach ($setting in $dscXml)
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing windows feature $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) windows feature settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'xWinEventLog' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WinEventLogRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[xWinEventLog\]"}

                foreach ($setting in $dscXml)
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing windows event log $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) windows event log settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Dns Root Hints' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.DnsServerRootHintRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[script\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing DNS Root Hint setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) DNS Root Hint settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Dns Server Settings' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.DnsServerSettingRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[xDnsServerSetting\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing Dns Server setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) Dns Server settings" {
                    $hasAllSettings | Should -Be $true
                }
            }
        }

        Describe "Windows DNS $($stig.TechnologyVersion) $($stig.StigVersion) Single SkipRule/RuleType mof output" {

            $skipRule = Get-Random -InputObject $dscXml.DISASTIG.DnsServerSettingRule.Rule.id
            $skipRuleType = "PermissionRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
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
                $dscXml = $dscXml.DISASTIG.PermissionRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $dscXml = $dscXml.count + $skipRule.count
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $dscXml Skipped settings" {
                    $dscMof.count | Should -Be $dscXml
                }
            }
        }

        Describe "Windows DNS $($stig.TechnologyVersion) $($stig.StigVersion) Multiple SkipRule/SkipType mof output" {

            $skipRule = Get-Random -InputObject $dscXml.DISASTIG.DnsServerSettingRule.Rule.id -Count 2
            $skipRuleType = @('PermissionRule','UserRightRule')

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
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
                $dscPermissionlRuleXml = $dscXml.DISASTIG.PermissionRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $dscUserRightRuleXml = $dscXml.DISASTIG.UserRightRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $expectedSkipRuleCount = $dscPermissionlRuleXml.count + $dscUserRightRuleXml.count + $skipRule.count
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $expectedSkipRuleCount Skipped settings" {
                    $dscMof.count | Should -Be $expectedSkipRuleCount
                }
            }
        }

        Describe "Windows DNS $($stig.TechnologyVersion) $($stig.StigVersion) Exception mof output" {

            $exceptionRule = Get-Random -InputObject $dscXml.DISASTIG.DnsServerSettingRule.Rule
            $exception = $exceptionRule.id

            It "Should compile the MOF with STIG exception $exception without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
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
