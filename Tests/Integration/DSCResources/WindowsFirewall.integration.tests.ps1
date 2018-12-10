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
        
        Describe "Windows Firewall $($stig.stigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should Not throw
            }

           # [xml] $dscXml = Get-Content -Path $stig.Path

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'Registry' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.RegistryRule.Rule
                $dscMof = $instances |
                    Where-Object -FilterScript {$PSItem.ResourceID -match "\[xRegistry\]"} 

                foreach ($setting in $dscXml)
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

        Describe "Windows Firewall $($stig.stigVersion) Single SkipRule/RuleType mof output"{
            $SkipRule     = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id
            $SkipRuleType = "Registry"

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType 
                } | Should not throw
            }

            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $dscXml = $dscXml.DISASTIG.RegistryRule.Rule | Where-Object -FilterScript {$_.ConversionStatus -eq "pass"}
                $dscXml = ($($dscXml.Count) + $($SkipRule.Count))
               
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
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
