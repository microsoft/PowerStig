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

                foreach ( $setting in $dscXml )
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

                foreach ($setting in $dscXmlPermissionPolicy)
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
                    Where-Object {$PSItem.ResourceID -match "\[xRegistry\]" -or $PSItem.ResourceID -match "\[cAdministrativeTemplateSetting\]"}

                foreach ( $setting in $dscXml )
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

            Context 'WMI' {
                $hasAllSettings = $true
                $dscXml    = $dscXml.DISASTIG.WmiRule.Rule
                $dscMof   = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[script\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing wmi setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) wmi settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'Services' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.ServiceRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[xService\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing service setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) service settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'AccountPolicy' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.AccountPolicyRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[AccountPolicy\]"}

                foreach ( $setting in $dscXml )
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

                foreach ( $setting in $dscXml )
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

                foreach ( $setting in $dscXml )
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

                foreach ($setting in $dscXml)
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

            $SkipRule     = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id
            $SkipRuleType = "AuditPolicyRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion  `
                        -OsRole $stig.TechnologyRole `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType `
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

            $SkipRule     = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id -Count 2
            $SkipRuleType = @('AuditPolicyRule','AccountPolicyRule')

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion  `
                        -OsRole $stig.TechnologyRole `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType `
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

                $dscXml = ($($dscAuditXml.Count) + $($dscPermissionXml.count) + $($SkipRule.Count))

                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $dscXml Skipped settings" {
                    $dscMof.count | Should Be $dscXml
                }
            }
        }

        Describe "Windows $($stig.TechnologyVersion) $($stig.TechnologyRole) $($stig.StigVersion) Exception mof output"{
            
            If (-not $ExceptionRuleValueData)
            {   
                $ExceptionRule = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule
                $Exception = $ExceptionRule.ID
                $ExceptionRuleValueData = $ExceptionRule.ValueData
            }

            It "Should compile the MOF with STIG exception $($Exception) without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion  `
                        -OsRole $stig.TechnologyRole `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -Exception $Exception
                } | Should not throw
            }
        }
    }
    #endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
