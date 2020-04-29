using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
. $configFile

$stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

foreach ($stig in $stigList)
{
    Describe "Vsphere $($stig.TechnologyVersion) $($stig.StigVersion) mof output" {

        It 'Should compile the MOF without throwing' {
            {
                $password = "ThisIsAPlaintextPassword" | ConvertTo-SecureString -AsPlainText -Force
                $username = "Administrator"
                $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
                $cd = @{
                    AllNodes = @(
                        @{
                            NodeName = 'localhost'
                            PSDscAllowDomainUser = $true
                            PSDscAllowPlainTextPassword = $true
                        }
                    )
                }

                Vsphere_config `
                -Version $stig.TechnologyVersion `
                -OutputPath $TestDrive `
                -ConfigurationData $cd `
                -Credential $credential
            } | Should -Not -Throw
        }

        $orgSettingsPath = $stig.Path.Replace('.xml', '.org.default.xml')
        $powerstigXml = [xml](Get-Content -Path $stig.Path) |
            Remove-DscResourceEqualsNone | Remove-SkipRuleBlankOrgSetting -OrgSettingPath $orgSettingsPath

        if (Test-AutomatableRuleType -StigObject $powerstigXml.ParentNode)
        {
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $ruleList = ($powerstigXml | Get-Member -Name "Vsphere*Rule").Name
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            foreach ($rule in $rulelist)
            {
                Context "When $rule" {
                    $hasAllSettings = $true
                    $dscXmlRule = @($powerstigXml.$rule.Rule)
                    $resourceMatch = Get-ResourceMatchStatement -RuleName $rule
                    $dscMof = $instances |
                        Where-Object -FilterScript {$PSItem.ResourceID -match $resourceMatch}

                    foreach ($setting in $dscXmlRule)
                    {
                        if (-not ($dscMof.ResourceID -match $setting.Id) )
                        {
                            Write-Warning -Message "Missing $rule Setting $($setting.Id)"
                            $hasAllSettings = $false
                        }
                    }

                    It "Should have $($dscXmlRule.Count) $rule settings" {
                        $hasAllSettings | Should -Be $true
                    }
                }
            }
        }
    }
}
