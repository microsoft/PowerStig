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

        Describe "Windows $($Stig.TechnologyVersion) $($Stig.TechnologyRole) $($Stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion  `
                        -OsRole $Stig.TechnologyRole `
                        -StigVersion $Stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"

            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)

            Context 'AuditPolicy' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.AuditPolicyRule.Rule
                $DscMof = $Instances |
                Where-Object {$PSItem.ResourceID -match "\[AuditPolicySubcategory\]"}

                foreach ( $Setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "Missing Audit Policy Setting $($Setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) Audit Policy settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'Permissions' {
                $HasAllSettings = $true
                <#
                    https://github.com/Microsoft/PowerStigDsc/issues/1
                    Once the Composite is updated to configure ActiveDirectoryAuditRuleEntry,
                    remove '-and $PSItem.dscResource -ne "ActiveDirectoryAuditRuleEntry"' from the
                    following where cmdlet
                #>
                $dscXmlPermissionPolicy = $DscXml.DISASTIG.PermissionRule.Rule |
                    Where-Object { $PSItem.conversionstatus -eq 'pass' -and
                                   $PSItem.dscResource -ne "ActiveDirectoryAuditRuleEntry"}
                $dscMofPermissionPolicy = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[NTFSAccessEntry\]|\[RegistryAccessEntry\]"}

                foreach ($Setting in $dscXmlPermissionPolicy)
                {
                    If (-not ($dscMofPermissionPolicy.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "Missing permission setting $($Setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($dscXmlPermissionPolicy.Count) permission settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'Registry' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.RegistryRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[xRegistry\]" -or $PSItem.ResourceID -match "\[cAdministrativeTemplateSetting\]"}

                foreach ( $Setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "Missing registry Setting $($Setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) Registry settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'WMI' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.WmiRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[script\]"}

                foreach ( $Setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "Missing wmi setting $($Setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) wmi settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'Services' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.ServiceRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[xService\]"}

                foreach ( $Setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "Missing service setting $($Setting.Id)"
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

                foreach ( $Setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "Missing security setting $($Setting.Id)"
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

                foreach ( $Setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "Missing user right $($Setting.Id)"
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

                foreach ( $Setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "Missing security setting $($Setting.Id)"
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

                foreach ($Setting in $DscXml)
                {
                    If (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "Missing windows feature $($Setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) windows feature settings" {
                    $HasAllSettings | Should -Be $true
                }
            }
        }

        Describe "Windows $($Stig.TechnologyVersion) $($Stig.TechnologyRole) $($Stig.StigVersion) Single SkipRule/RuleType mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.RegistryRule.Rule.id
            $SkipRuleType = "AuditPolicyRule"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -OsRole $Stig.TechnologyRole `
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
                $DscXml = $DscXml.DISASTIG.AuditPolicyRule.Rule | Where-Object {$_.ConversionStatus -eq 'pass'}
                $DscXml = $DscXml.Count + $SkipRule.Count

                $DscMof = $Instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $DscXml Skipped settings" {
                    $DscMof.Count | Should -Be $DscXml
                }
            }
        }

        Describe "Windows $($Stig.TechnologyVersion) $($Stig.TechnologyRole) $($Stig.StigVersion) Multiple SkipRule/RuleType mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.RegistryRule.Rule.id -Count 2
            $SkipRuleType = @('AuditPolicyRule','AccountPolicyRule')

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -OsRole $Stig.TechnologyRole `
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
                $dscAuditXml = $DscXml.DISASTIG.AuditPolicyRule.Rule | Where-Object {$_.ConversionStatus -eq "Pass"}
                $dscPermissionXml = $DscXml.DISASTIG.AccountPolicyRule.Rule | Where-Object {$_.ConversionStatus -eq "Pass"}

                $DscXml = $dscAuditXml.Count + $dscPermissionXml.Count + $SkipRule.Count
                $DscMof = $Instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $DscXml Skipped settings" {
                    $DscMof.Count | Should -Be $DscXml
                }
            }
        }

        Describe "Windows $($Stig.TechnologyVersion) $($Stig.TechnologyRole) $($Stig.StigVersion) Exception mof output" {

            $ExceptionRule = Get-Random -InputObject $DscXml.DISASTIG.RegistryRule.Rule
            $Exception = $ExceptionRule.ID

            It "Should compile the MOF with STIG exception $($Exception) without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $Stig.TechnologyVersion `
                        -OsRole $Stig.TechnologyRole `
                        -StigVersion $Stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
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
