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

    #region Test Setup
    $configPath = 'C:\Windows\Sun\Java\Deployment\deployment.config'
    $propertiesPath = 'C:\Windows\Java\Deployment\deployment.properties'
    #endregionTest Setup

    #region Integration Tests
    foreach ($stig in $stigList)
    {
        [xml] $dscXml = Get-Content -Path $stig.Path

        Describe "OracleJRE 8 $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -ConfigPath $configPath `
                        -PropertiesPath $propertiesPath `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'KeyValuePairRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.FileContentRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[KeyValuePairFile\]"}

                foreach ($setting in $dscXml)
                {
                    if (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing KeyValuePairFile Setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) KeyValuePairFile settings" {
                    $hasAllSettings | Should -Be $true
                }
            }
        }
        ### Begin DO NOT REMOVE Core Tests
        $technologyConfig = "$($script:DSCCompositeResourceName)_config"

        $skipRule = Get-Random -InputObject $dscXml.DISASTIG.FileContentRule.Rule.id
        $skipRuleType = $null
        $expectedSkipRuleTypeCount = 0

        $skipRuleMultiple = Get-Random -InputObject $dscXml.DISASTIG.FileContentRule.Rule.id -Count 2
        $skipRuleTypeMultiple = $null
        $expectedSkipRuleTypeMultipleCount = 0

        $exception = Get-Random -InputObject $dscXml.DISASTIG.FileContentRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $dscXml.DISASTIG.FileContentRule.Rule.id -Count 2

        $userSettingsPath = "$PSScriptRoot\stigdata.usersettings.ps1"
        . $userSettingsPath
        ### End DO NOT REMOVE Core Tests
    }
    #endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
