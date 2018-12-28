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
                } | Should -Not -Throw
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
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing SqlScriptQuery $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.id.count) SqlScriptQueryRule settings" {
                    $hasAllSettings | Should -Be $true
                }
            }
        }
        #### Begin DO NOT REMOVE Core Tests
        $technologyConfig = "$($script:DSCCompositeResourceName)$($stig.TechnologyRole)_config"

        $skipRule = Get-Random -InputObject $dscXml.DISASTIG.SqlScriptQueryRule.Rule.id
        $skipRuleType = "DocumentRule"
        $expectedSkipRuleTypeCount = $dscXml.DISASTIG.DocumentRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $dscXml.DISASTIG.DocumentRule.Rule.id -Count 2
        $skipRuleTypeMultiple = $null
        $expectedSkipRuleTypeMultipleCount = 0

        $exception = Get-Random -InputObject $dscXml.DISASTIG.SqlScriptQueryRule.Rule.id
        $exceptionMultiple = $null

        $userSettingsPath =  "$PSScriptRoot\stigdata.usersettings.ps1"
        . $userSettingsPath
        ### End DO NOT REMOVE Core Tests
    }
    #endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
