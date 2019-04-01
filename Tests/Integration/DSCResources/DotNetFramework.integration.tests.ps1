$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $configFile

    $stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    foreach ($stig in $stigList)
    {
        Describe "Framework $($stig.TechnologyVersion) $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                    -FrameworkVersion $stig.TechnologyVersion `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            [xml] $dscXml = Get-Content -Path $stig.Path

            if (Test-AutomatableRuleType -StigObject $dscXml)
            {
                $configurationDocumentPath = "$TestDrive\localhost.mof"

                $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

                Context 'Registry' {
                    $hasAllSettings = $true
                    $dscXml = @($dscXml.DISASTIG.RegistryRule.Rule)
                    $dscMof = $instances |
                        Where-Object {$PSItem.ResourceID -match "\[Registry\]"}

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
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

