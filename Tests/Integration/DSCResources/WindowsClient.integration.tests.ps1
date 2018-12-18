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

        Describe "Windows $($stig.TechnologyVersion) $($stig.TechnologyRole) $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'AccountPolicy' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.AccountPolicyRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[AccountPolicy\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing AccountPolicy setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) AccountPolicy settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'AuditPolicy' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.AuditPolicyRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[AuditPolicySubcategory\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing Audit Policy Setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) Audit Policy settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Group' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.GroupRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[Group\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing Group Setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) Group settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Permissions' {
                $hasAllSettings = $true
                <#
                    https://github.com/Microsoft/PowerStigDsc/issues/1
                    Once the Composite is updated to configure ActiveDirectoryAuditRuleEntry,
                    remove '-and $PSItem.dscResource -ne "ActiveDirectoryAuditRuleEntry"' from the
                    following where cmdlet
                #>
                $dscXmlPermissionPolicy = $dscXml.DISASTIG.PermissionRule.Rule |
                    Where-Object { $PSItem.conversionstatus -eq 'pass' -and
                                   $PSItem.dscResource -ne 'ActiveDirectoryAuditRuleEntry'}
                $dscMofPermissionPolicy = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[NTFSAccessEntry\]|\[RegistryAccessEntry\]"}

                foreach ($setting in $dscXmlPermissionPolicy)
                {
                    If (-not ($dscMofPermissionPolicy.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing permission setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXmlPermissionPolicy.count) permission settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'ProcessMitigation' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.ProcessMitigation.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[ProcessMitigation\]"}

                foreach ($setting in $dscXml)
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing ProcessMitigation setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) ProcessMitigation settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Registry' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.RegistryRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[xRegistry\]|\[cAdministrativeTemplateSetting\]"}

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

            Context 'SecurityOption' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.SecurityOptionRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[SecurityOption\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing SecurityOption Setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) SecurityOption settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Service' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.ServiceRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[xService\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing Service Setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) Service settings" {
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

            Context 'Windows Feature' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WindowsFeatureRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[WindowsOptionalFeature\]"}

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

            Context 'WMI' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WmiRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[Script\]"}

                foreach ($setting in $dscXml)
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing WMI setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) WMI settings" {
                    $hasAllSettings | Should -Be $true
                }
            }
        }

        Describe "Windows $($stig.TechnologyVersion) $($stig.TechnologyRole) $($stig.StigVersion) Single SkipRule/RuleType mof output" {

            $skipRule = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id
            $skipRuleType = "AuditPolicyRule"

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
                $dscXml = $dscXml.DISASTIG.AuditPolicyRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $dscXml = $dscXml.count + $skipRule.count

                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $dscXml Skipped settings" {
                    $dscMof.count | Should -Be $dscXml
                }
            }
        }

        Describe "Windows $($stig.TechnologyVersion) $($stig.TechnologyRole) $($stig.StigVersion) Multiple SkipRule/RuleType mof output" {

            $skipRule = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id -Count 2
            $skipRuleType = @('AuditPolicyRule','AccountPolicyRule')

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
                $dscAuditXml = $dscXml.DISASTIG.AuditPolicyRule.Rule | Where-Object {$_.ConversionStatus -eq "Pass"}
                $dscPermissionXml = $dscXml.DISASTIG.AccountPolicyRule.Rule | Where-Object {$_.ConversionStatus -eq "Pass"}

                $dscXml = $dscAuditXml.count + $dscPermissionXml.count + $skipRule.count

                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $dscXml Skipped settings" {
                    $dscMof.count | Should -Be $dscXml
                }
            }
        }

        Describe "Windows $($stig.TechnologyVersion) $($stig.TechnologyRole) $($stig.StigVersion) Exception mof output" {

            $exceptionRule = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule
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
