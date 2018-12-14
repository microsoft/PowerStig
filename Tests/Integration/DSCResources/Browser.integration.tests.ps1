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

        Describe "Browser $($stig.TechnologyRole) $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -BrowserVersion $stig.TechnologyRole `
                        -StigVersion $stig.stigVersion `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'Registry' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.RegistryRule.Rule
                $dscMof = $instances |
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
        }

        Describe "Browser $($stig.TechnologyRole) $($stig.StigVersion) Single SkipRule mof output" {

            $SkipRule = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -BrowserVersion $stig.TechnologyRole `
                        -StigVersion $stig.stigVersion `
                        -SkipRule $SkipRule `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $dscXml = $($SkipRule.Count)
                [array] $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $dscXml Skipped settings" {
                    $dscMof.count | Should Be $dscXml
                }
            }
        }

        Describe "Browser $($stig.TechnologyRole) $($stig.StigVersion) Multiple SkipRule mof output" {

            $SkipRule = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id -Count 2

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -BrowserVersion $stig.TechnologyRole `
                        -StigVersion $stig.stigVersion `
                        -SkipRule $SkipRule `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $expectedSkipRuleCount = ($($SkipRule.Count))
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $expectedSkipRuleCount Skipped settings" {
                    $dscMof.count | Should Be $expectedSkipRuleCount
                }
            }
        }

        Describe "Browser $($stig.TechnologyRole) $($stig.StigVersion) Exception mof output"{

            If (-not $ExceptionRuleValueData)
            {   
                $ExceptionRule = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule
                $Exception = $ExceptionRule.ID
                $ExceptionRuleValueData = $ExceptionRule.ValueData
            }

            It "Should compile the MOF with STIG exception $($Exception) without throwing" {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -BrowserVersion $stig.TechnologyRole `
                        -StigVersion $stig.stigVersion `
                        -OutputPath $TestDrive `
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
