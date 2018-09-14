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
    Foreach ($stig in $stigList)
    {
        [xml] $dscXml = Get-Content -Path $stig.Path

        Describe "Windows $($stig.TechnologyVersion) $($stig.TechnologyRole) $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion  `
                        -OsRole $stig.TechnologyRole `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'AuditPolicy' {
                $hasAllSettings = $true
                $dscXml         = $dscXml.DISASTIG.AuditPolicyRule.Rule
                $dscMof         = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[AuditPolicySubcategory\]"}

                Foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing Audit Policy Setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) Audit Policy settings" {
                    $hasAllSettings | Should Be $true
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
                    Where-Object { $PSItem.conversionstatus -eq "pass" -and
                                   $PSItem.dscResource -ne "ActiveDirectoryAuditRuleEntry"}
                $dscMofPermissionPolicy = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[NTFSAccessEntry\]|\[RegistryAccessEntry\]"}

                Foreach ($setting in $dscXmlPermissionPolicy)
                {
                    If (-not ($dscMofPermissionPolicy.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing permission setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXmlPermissionPolicy.Count) permission settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'Registry' {
                $hasAllSettings = $true
                $dscXml   = $dscXml.DISASTIG.RegistryRule.Rule
                $dscMof   = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[xRegistry\]"}

                Foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing registry Setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) Registry settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'AccountPolicy' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.AccountPolicyRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[AccountPolicy\]"}

                Foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing security setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) security settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'UserRightsAssignment' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.UserRightRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[UserRightsAssignment\]"}

                Foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing user right $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) user rights settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'SecurityOption' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.SecurityOptionRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[SecurityOption\]"}

                Foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing security setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) security settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'Windows Feature' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WindowsFeatureRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[WindowsFeature\]"}

                Foreach ($setting in $dscXml)
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing windows feature $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) windows feature settings" {
                    $hasAllSettings | Should Be $true
                }
            }
        }

        Describe "Windows $($stig.TechnologyVersion) $($stig.TechnologyRole) $($stig.StigVersion) Single SkipRule/RuleType mof output" {

            $skipRule     = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id
            $skipRuleType = "AuditPolicyRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion  `
                        -OsRole $stig.TechnologyRole `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -SkipRule $skipRule `
                        -SkipRuleType $skipRuleType `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $dscXml = $dscXml.DISASTIG.AuditPolicyRule.Rule | Where-Object {$_.ConversionStatus -eq "pass"}
                $dscXml = ($($dscXml.Count) + $($SkipRule.Count))

                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $dscXml Skipped settings" {
                    $dscMof.count | Should Be $dscXml
                }
            }
        }

        Describe "Windows $($stig.TechnologyVersion) $($stig.TechnologyRole) $($stig.StigVersion) Multiple SkipRule/RuleType mof output" {

            $skipRule     = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id -Count 2
            $skipRuleType = @('AuditPolicyRule','AccountPolicyRule')

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion  `
                        -OsRole $stig.TechnologyRole `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -SkipRule $skipRule `
                        -SkipRuleType $skipRuleType `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $dscAuditXml = $dscXml.DISASTIG.AuditPolicyRule.Rule | Where-Object {$_.ConversionStatus -eq "Pass"}
                $dscPermissionXml = $dscXml.DISASTIG.AccountPolicyRule.Rule | Where-Object {$_.ConversionStatus -eq "Pass"}

                $dscXml = ($($dscAuditXml.Count) + $($dscPermissionXml.count) + $($skipRule.Count))

                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $dscXml Skipped settings" {
                    $dscMof.count | Should Be $dscXml
                }
            }
        }
    }
    #endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
