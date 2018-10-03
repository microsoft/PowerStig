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
        Describe "OracleJRE 8 $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -ConfigPath $configPath `
                        -PropertiesPath $propertiesPath `
                        -StigVersion $stig.stigVersion `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            [xml] $dscXml = Get-Content -Path $stig.Path

            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'KeyValuePairRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.FileContentRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[KeyValuePairFile\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing KeyValuePairFile Setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) KeyValuePairFile settings" {
                    $hasAllSettings | Should Be $true
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
