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

        Describe "Windows DNS $($Stig.TechnologyVersion) $($Stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"

            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)

            Context 'Registry' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.RegistryRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[xRegistry\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing registry Setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) Registry settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'Services' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.ServiceRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[xService\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing service setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) service settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'AccountPolicy' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.AccountPolicyRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[AccountPolicy\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing security setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) security settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'UserRightsAssignment' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.UserRightRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[UserRightsAssignment\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing user right $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) user rights settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'SecurityOption' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.SecurityOptionRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[SecurityOption\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing security setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) security settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'Windows Feature' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.WindowsFeatureRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[WindowsFeature\]"}

                foreach ($setting in $DscXml)
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing windows feature $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) windows feature settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'xWinEventLog' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.WinEventLogRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[xWinEventLog\]"}

                foreach ($setting in $DscXml)
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing windows event log $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) windows event log settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'Dns Root Hints' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.DnsServerRootHintRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[script\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing DNS Root Hint setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) DNS Root Hint settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'Dns Server Settings' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.DnsServerSettingRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[xDnsServerSetting\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing Dns Server setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) Dns Server settings" {
                    $HasAllSettings | Should -Be $true
                }
            }
        }

        Describe "Windows DNS $($Stig.TechnologyVersion) $($Stig.StigVersion) Single SkipRule/RuleType mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.DnsServerSettingRule.Rule.id
            $SkipRuleType = "PermissionRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
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
                $DscXml = $DscXml.DISASTIG.PermissionRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $DscXml = $DscXml.Count + $SkipRule.Count
                $DscMof = $Instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $DscXml Skipped settings" {
                    $DscMof.Count | Should -Be $DscXml
                }
            }
        }

        Describe "Windows DNS $($Stig.TechnologyVersion) $($Stig.StigVersion) Multiple SkipRule/SkipType mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.DnsServerSettingRule.Rule.id -Count 2
            $SkipRuleType = @('PermissionRule','UserRightRule')

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
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
                $dscPermissionlRuleXml = $DscXml.DISASTIG.PermissionRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $dscUserRightRuleXml = $DscXml.DISASTIG.UserRightRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $ExpectedSkipRuleCount = $dscPermissionlRuleXml.Count + $dscUserRightRuleXml.Count + $SkipRule.Count
                $DscMof = $Instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $ExpectedSkipRuleCount Skipped settings" {
                    $DscMof.Count | Should -Be $ExpectedSkipRuleCount
                }
            }
        }

        Describe "Windows DNS $($Stig.TechnologyVersion) $($Stig.StigVersion) Exception mof output" {

            $ExceptionRule = Get-Random -InputObject $DscXml.DISASTIG.DnsServerSettingRule.Rule
            $Exception = $ExceptionRule.ID

            It "Should compile the MOF with STIG exception $($Exception) without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
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
