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

        Describe " $($Stig.TechnologyRole) $($Stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -StigVersion $Stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"
            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)

            Context 'FileContentRule' {
                $HasAllSettings = $true
                $DscXml = $DscXml.DISASTIG.FileContentRule.Rule
                $DscMof = $Instances |
                    Where-Object {$PSItem.ResourceID -match "\[ReplaceText\]"}

                foreach ( $Setting in $DscXml )
                {
                    If (-not ($DscMof.ResourceID -match $Setting.Id) )
                    {
                        Write-Warning -Message "Missing FileContent Setting $($Setting.Id)"
                        $HasAllSettings = $false
                    }
                }

                It "Should have $($DscXml.Count) FileContent settings" {
                    $HasAllSettings | Should -Be $true
                }
            }
        }

        Describe " $($Stig.TechnologyRole) $($Stig.StigVersion) Single SkipRule mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.FileContentRule.Rule.id

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -StigVersion $Stig.StigVersion `
                        -SkipRule $SkipRule `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            #region Gets the mof content
            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"
            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $DscXml = $SkipRule.Count
                $DscMof = @($Instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"})
                #endregion

                It "Should have $DscXml Skipped settings" {
                    $DscMof.Count | Should -Be $DscXml
                }
            }
        }

        Describe " $($Stig.TechnologyRole) $($Stig.StigVersion) Multiple SkipRule mof output" {

            $SkipRule = Get-Random -InputObject $DscXml.DISASTIG.FileContentRule.Rule.id -Count 2

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -StigVersion $Stig.StigVersion `
                        -SkipRule $SkipRule `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            #region Gets the mof content
            $ConfigurationDocumentPath = "$TestDrive\localhost.mof"
            $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $ExpectedSkipRuleCount = $SkipRule.Count
                $DscMof = $Instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $ExpectedSkipRuleCount Skipped settings" {
                    $DscMof.Count | Should -Be $ExpectedSkipRuleCount
                }
            }
        }

        Describe " $($Stig.TechnologyRole) $($Stig.StigVersion) Exception mof output" {

            $ExceptionRule = Get-Random -InputObject $DscXml.DISASTIG.FileContentRule.Rule
            $Exception = $ExceptionRule.ID

            It "Should compile the MOF with STIG exception $($Exception) without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
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
