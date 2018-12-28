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
    $WebsiteName = @('WarioSite', 'DKSite')
    $WebAppPool = @('MushroomBeach', 'ToadHarbor')
    #endregionTest Setup

    #region Tests
    foreach ($stig in $stigList)
    {
        [xml] $dscXml = Get-Content -Path $stig.Path

        Describe "IIS Site $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebAppPool $WebAppPool `
                        -WebsiteName $WebsiteName `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'IisLoggingRule' {
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebSite\]"}

                It "Should have $($WebsiteName.count) xWebSite settings" {
                    $dscMof.count | Should -Be $WebsiteName.count
                }
            }

            Context 'WebConfigurationPropertyRule' {

                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebConfigProperty\]"}

                foreach ($Website in $WebsiteName)
                {
                    foreach ($setting in $dscXml)
                    {
                        if (-not ($dscMof.ResourceID -match $setting.id))
                        {
                            Write-Warning -Message "$Website missing WebConfigurationPropertyRule Setting $($setting.id)"
                            $hasAllSettings = $false
                        }
                    }
                }

                It "Should have $($dscXml.count) WebConfigurationPropertyRule settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'WebAppPoolRule' {
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebAppPool\]"}

                It "Should have $($WebsiteName.count) xWebAppPool settings" {
                    $dscMof.count | Should -Be $WebAppPool.count
                }
            }

            Context 'MimeTypeRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.MimeTypeRule.Rule
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xIisMimeTypeMapping\]"}

                foreach ($Website in $WebsiteName)
                {
                    foreach ($setting in $dscXml)
                    {
                        if (-not ($dscMof.ResourceID -match $setting.id))
                        {
                            Write-Warning -Message "$Website ,missing MimeTypeRule Setting $($setting.id)"
                            $hasAllSettings = $false
                        }
                    }
                }

                It "Should have $($dscXml.count) WebConfigurationPropertyRule settings" {
                    $hasAllSettings | Should -Be $true
                }
            }
        }

        #### Begin DO NOT REMOVE Core Tests
        $technologyConfig = "$($script:DSCCompositeResourceName)_config"

        $skipRule = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id
        $skipRuleType = "IisLoggingRule"
        $expectedSkipRuleTypeCount = $dscXml.DISASTIG.IisLoggingRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $dscXml.DISASTIG.MimeTypeRule.Rule.id -Count 2
        $skipRuleTypeMultiple = @('WebAppPoolRule','IisLoggingRule')
        $expectedSkipRuleTypeMultipleCount = $dscXml.DISASTIG.WebAppPoolRule.ChildNodes.Count + $dscXml.DISASTIG.IisLoggingRule.ChildNodes.Count

        $exception = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $dscXml.DISASTIG.MimeTypeRule.Rule.id -Count 2

        $userSettingsPath =  "$PSScriptRoot\stigdata.usersettings.ps1"
        . $userSettingsPath
        ### End DO NOT REMOVE Core Tests
    }
    #endregion Tests
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
