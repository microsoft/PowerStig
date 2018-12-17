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
                        -OsVersion $Stig.TechnologyVersion `
                        -StigVersion $Stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"

            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)

            Context 'AccountPolicy' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.AccountPolicyRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[AccountPolicy\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing AccountPolicy setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) AccountPolicy settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'AuditPolicy' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.AuditPolicyRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[AuditPolicySubcategory\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing Audit Policy Setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) Audit Policy settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'Group' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.GroupRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[Group\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing Group Setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) Group settings" {
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
                                   $PSItem.dscResource -ne 'ActiveDirectoryAuditRuleEntry'}
                $dscMofPermissionPolicy = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[NTFSAccessEntry\]|\[RegistryAccessEntry\]"}

                foreach ($setting in $dscXmlPermissionPolicy)
                {
                    If (-not ($dscMofPermissionPolicy.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing permission setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($dscXmlPermissionPolicy.Count) permission settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'ProcessMitigation' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.ProcessMitigation.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[ProcessMitigation\]"}

                foreach ($setting in $DscXml)
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing ProcessMitigation setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) ProcessMitigation settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'Registry' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.RegistryRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[xRegistry\]|\[cAdministrativeTemplateSetting\]"}

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

            Context 'SecurityOption' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.SecurityOptionRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[SecurityOption\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing SecurityOption Setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) SecurityOption settings" {
                    $HasAllSettings | Should -Be $true
                }
            }

            Context 'Service' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.ServiceRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[xService\]"}

                foreach ( $setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing Service Setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) Service settings" {
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

            Context 'Windows Feature' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.WindowsFeatureRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[WindowsOptionalFeature\]"}

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

            Context 'WMI' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.WmiRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[Script\]"}

                foreach ($setting in $DscXml)
                {
                    If (-not ($DscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing WMI setting $($setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) WMI settings" {
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
