$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $ConfigFile

    $stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    #region Test Setup
    $websiteName = @('WarioSite', 'DKSite')
    $webAppPool = @('MushroomBeach', 'ToadHarbor')
    #endregionTest Setup

    #region Tests
    foreach ($stig in $stigList)
    {
        Describe "IIS Site $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -WebAppPool $WebAppPool `
                        -WebsiteName $websiteName `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            [xml] $dscXml = Get-Content -Path $stig.Path

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'IisLoggingRule' {
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebSite\]"}

                It "Should have $($websiteName.count) xWebSite settings" {
                    $dscMof.count | Should Be $websiteName.count
                }
            }

            Context 'WebConfigurationPropertyRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[xWebConfigProperty\]"}

                foreach ($website in $websiteName)
                {
                    foreach ($setting in $dscXml)
                    {
                        if (-not ($dscMof.ResourceID -match $setting.Id) )
                        {
                            Write-Warning -Message "$website missing WebConfigurationPropertyRule Setting $($setting.Id)"
                            $hasAllSettings = $false
                        }
                    } 
                }

                It "Should have $($dscXml.Count) WebConfigurationPropertyRule settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'WebAppPoolRule' {
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xWebAppPool\]"}

                It "Should have $($websiteName.count) xWebAppPool settings" {
                    $dscMof.count | Should Be $webAppPool.count
                }
            }

            Context 'MimeTypeRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.MimeTypeRule.Rule
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[xIisMimeTypeMapping\]"}

                foreach ($website in $websiteName) 
                {
                    foreach ($setting in $dscXml) 
                    {
                        if (-not ($dscMof.ResourceID -match $setting.Id) ) 
                        {
                            Write-Warning -Message "$website ,missing MimeTypeRule Setting $($setting.Id)"
                            $hasAllSettings = $false
                        }
                    }
                }

                It "Should have $($dscXml.Count) WebConfigurationPropertyRule settings" {
                    $hasAllSettings | Should Be $true
                }
            }
        }
    }
    #endregion Tests
}
finally 
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
