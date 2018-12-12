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

        Describe "SqlServer $($stig.TechnologyRole) $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)$($stig.TechnologyRole)_config" `
                        -SqlVersion $stig.TechnologyVersion `
                        -SqlRole $stig.TechnologyRole`
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'SqlScriptQuery' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.SqlScriptQueryRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[SqlScriptQuery\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing SqlScriptQuery $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Id.Count) SqlScriptQueryRule settings" {
                    $hasAllSettings | Should Be $true
                }
            }
        }
    
        Describe "SqlServer $($stig.TechnologyRole) $($stig.TechnologyVersion) $($stig.StigVersion) Single SkipRule/RuleType mof output" {

            $SkipRule = Get-Random -InputObject $dscXml.DISASTIG.SqlScriptQueryRule.Rule.id
            $SkipRuleType = "DocumentRule"
        
            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)$($stig.TechnologyRole)_config" `
                        -SqlVersion $stig.TechnologyVersion `
                        -SqlRole $stig.TechnologyRole`
                        -StigVersion $stig.StigVersion `
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
                $dscXml = $dscXml.DISASTIG.DocumentRule.Rule | Where-Object {$_.ConversionStatus -eq "pass"}
                $dscXml = ($($dscXml.Count) + $($SkipRule.Count))
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion
        
                It "Should have $dscXml Skipped settings" {
                    $dscMof.count | Should Be $dscXml
                }
            }
        }

        Describe "SqlServer $($stig.TechnologyRole) $($stig.TechnologyVersion) $($stig.StigVersion) Multiple SkipRule/RuleType mof output" {
            
            $SkipRule = Get-Random -InputObject $dscXml.DISASTIG.SqlScriptQueryRule.Rule.id -Count 2
            $SkipRuleType = @('DocumentRule')
            
            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)$($stig.TechnologyRole)_config" `
                        -SqlVersion $stig.TechnologyVersion `
                        -SqlRole $stig.TechnologyRole`
                        -StigVersion $stig.StigVersion `
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
                $dscDocumentTypeRuleXml = $dscXml.DISASTIG.DocumentRule.Rule | Where-Object {$_.ConversionStatus -eq "pass"}
                $expectedSkipRuleCount = ($($dscDocumentTypeRuleXml.Count) + $($SkipRule.Count)) 
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion
              
                It "Should have $expectedSkipRuleCount Skipped settings" {
                    $dscMof.count | Should Be $expectedSkipRuleCount
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
