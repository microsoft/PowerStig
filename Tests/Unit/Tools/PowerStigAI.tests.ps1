. $PSScriptRoot\.tests.header.ps1

InModuleScope $script:ModuleName {
    Describe 'Convert-PowerStigZipFolder' -Tag 'tools' {
        It 'Should convert nested XCCDF files into a sibling conversions folder' {
            $sourcePath = Join-Path -Path $TestDrive -ChildPath 'source'
            $archivePath = Join-Path -Path $sourcePath -ChildPath 'sample.zip'
            $archiveContent = Join-Path -Path $TestDrive -ChildPath 'archive-content\nested'
            $null = New-Item -Path $archiveContent -ItemType Directory -Force
            '<Benchmark />' | Set-Content -Path (Join-Path $archiveContent 'sample-xccdf.xml')
            $null = New-Item -Path $sourcePath -ItemType Directory -Force
            Compress-Archive -Path (Join-Path $TestDrive 'archive-content\*') -DestinationPath $archivePath
            $script:conversionParameters = $null
            $converter = {
                param($Parameters)
                $script:conversionParameters = $Parameters
            }

            $result = Convert-PowerStigZipFolder -Path $sourcePath -Converter $converter

            @($result).Count | Should Be 1
            $result.Status | Should Be 'Converted'
            $result.Xccdf | Should Be 'sample-xccdf.xml'
            $result.Destination | Should Be (Join-Path $sourcePath 'conversions')
            $script:conversionParameters.Path | Should Match 'sample-xccdf.xml$'
            $script:conversionParameters.Destination | Should Be (Join-Path $sourcePath 'conversions')
            Test-Path -Path $script:conversionParameters.Path | Should Be $false
        }

        It 'Should skip an archive that contains no XCCDF file' {
            $sourcePath = Join-Path -Path $TestDrive -ChildPath 'source-no-xccdf'
            $archiveContent = Join-Path -Path $TestDrive -ChildPath 'archive-no-xccdf'
            $null = New-Item -Path $sourcePath -ItemType Directory -Force
            $null = New-Item -Path $archiveContent -ItemType Directory -Force
            'sample' | Set-Content -Path (Join-Path $archiveContent 'readme.txt')
            Compress-Archive -Path (Join-Path $archiveContent '*') `
                -DestinationPath (Join-Path $sourcePath 'sample.zip')

            $result = Convert-PowerStigZipFolder -Path $sourcePath -Converter { throw 'Should not run' }

            $result.Status | Should Be 'Skipped'
            $result.Error | Should Match 'No XCCDF file'
        }
    }

    Describe 'Invoke-PowerStigAzureAiNormalization' -Tag 'tools' {
        It 'Should request and parse strict normalized XCCDF content' {
            $script:requestBody = $null
            Mock Invoke-RestMethod {
                $script:requestBody = $Body | ConvertFrom-Json
                return [pscustomobject] @{
                    id          = 'response-1'
                    model       = 'gpt-5-mini'
                    status      = 'completed'
                    output_text = @{
                        correctedCheckContent = 'Registry Path: \Software\Example'
                        correctedFixText      = 'Registry Path: \Software\Example'
                        changes               = @('Corrected registry path label.')
                        confidence            = 'high'
                    } | ConvertTo-Json
                }
            }

            [xml] $xccdfRule = '<Group id="V-1"><Rule><title>Test rule</title><fixtext>RegistryPath\Software\Example</fixtext><check><check-content>RegistryPath\Software\Example</check-content></check></Rule></Group>'
            $context = [pscustomobject] @{
                XccdfRule = $xccdfRule.Group
                Rules     = @()
                Error     = $null
                Reason    = 'ConversionFailed'
            }
            $token = ConvertTo-SecureString -String 'test-token' -AsPlainText -Force

            $result = Invoke-PowerStigAzureAiNormalization -Context $context `
                -Endpoint 'https://example.services.ai.azure.com/openai/v1/' `
                -DeploymentName 'powerstig-gpt-5-mini' -AccessToken $token

            $result.RuleId | Should Be 'V-1'
            $result.Confidence | Should Be 'high'
            $result.CorrectedCheckContent | Should Be 'Registry Path: \Software\Example'
            $script:requestBody.model | Should Be 'powerstig-gpt-5-mini'
            $script:requestBody.store | Should Be $false
            $script:requestBody.text.format.type | Should Be 'json_schema'
            $script:requestBody.text.format.strict | Should Be $true
            $script:requestBody.instructions | Should Match 'must include canonical Registry Hive:'
            $script:requestBody.instructions | Should Match 'infer it only when'
            Assert-MockCalled Invoke-RestMethod -Times 1 -ParameterFilter {
                $Uri -eq 'https://example.services.ai.azure.com/openai/v1/responses'
            }
        }
    }

    Describe 'Invoke-PowerStigAzureAiManualReview' -Tag 'tools' {
        It 'Should request and parse a strict manual rule review' {
            $script:requestBody = $null
            Mock Invoke-RestMethod {
                $script:requestBody = $Body | ConvertFrom-Json
                return [pscustomobject] @{
                    id          = 'response-2'
                    model       = 'gpt-5-mini'
                    status      = 'completed'
                    output_text = @{
                        decision              = 'automation-gap'
                        suggestedRuleType     = 'RegistryRule'
                        rationale             = 'The check defines a concrete registry value.'
                        correctedCheckContent = 'Registry Path: \Software\Example'
                        correctedFixText      = 'Registry Path: \Software\Example'
                        changes               = @('Corrected registry path label.')
                        confidence            = 'high'
                    } | ConvertTo-Json
                }
            }

            [xml] $xccdfRule = '<Group id="V-2"><Rule><title>Manual test</title><fixtext>RegistryPath\Software\Example</fixtext><check><check-content>RegistryPath\Software\Example</check-content></check></Rule></Group>'
            $context = [pscustomobject] @{
                XccdfRule = $xccdfRule.Group
                Rules     = @([pscustomobject] @{Type = 'ManualRule' })
                Error     = $null
                Reason    = 'ManualReview'
            }
            $context.Rules[0].PSObject.TypeNames.Insert(0, 'ManualRule')
            $token = ConvertTo-SecureString -String 'test-token' -AsPlainText -Force

            $result = Invoke-PowerStigAzureAiManualReview -Context $context `
                -Endpoint 'https://example.services.ai.azure.com/openai/v1/' `
                -DeploymentName 'powerstig-gpt-5-mini' -AccessToken $token

            $result.RuleId | Should Be 'V-2'
            $result.Decision | Should Be 'automation-gap'
            $result.SuggestedRuleType | Should Be 'RegistryRule'
            $script:requestBody.store | Should Be $false
            $script:requestBody.text.format.name | Should Be 'PowerStigManualRuleReview'
            $script:requestBody.text.format.strict | Should Be $true
            $script:requestBody.instructions | Should Match 'Use automation-gap only'
            $script:requestBody.instructions | Should Match 'Use unsupported when'
            $script:requestBody.instructions | Should Match 'Never use automation-gap for a partial conversion'
            Assert-MockCalled Invoke-RestMethod -Times 1 -ParameterFilter {
                $Uri -eq 'https://example.services.ai.azure.com/openai/v1/responses'
            }
        }
    }
}