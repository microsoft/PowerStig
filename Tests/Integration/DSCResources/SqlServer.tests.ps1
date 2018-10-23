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

            [xml] $dscXml = Get-Content -Path $stig.Path

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
    }
    #endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
