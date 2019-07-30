[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))

Import-Module -Name (Join-Path -Path $moduleRoot -ChildPath 'DscResources\helper.psm1')

Describe 'Variables' {

    It 'Should export the resourcePath variable' {
        $resourcePath | Should Not BeNullOrEmpty
    }
}

Describe 'Functions' {

    Context 'Get-ResourceTitle' {

        [xml] $xml = Get-Content -Path $PSScriptRoot\helper.tests.data.xml

        $title = Get-ResourceTitle -Rule $xml.DISASTIG.RegistryRule.Rule

        It 'Title Should be in the correct format' {
            $title | Should Be "[V-1075][low][Display Shutdown Button]"
        }
    }

    Context 'Select-Rule' {

        It 'Should Exist' {
            Get-Command 'Select-Rule' | Should Not BeNullOrEmpty
        }
    }

    Context 'Format-FirefoxPreference' {

        It 'Should return a boolean as a string without double quotes' {
            $result = Format-FirefoxPreference -Value $true
            $result | Should -BeOftype 'String'
            $result | Should -Be 'True'
        }

        It 'Should return a string wrapped in double quotes' {
            $result = Format-FireFoxPreference -Value 'Meaning of Life'
            $result | Should -BeOftype 'String'
            $result | Should -Be '"Meaning of Life"'
        }

        It 'Should return and a number as a string without double quotes' {
            $result = Format-FireFoxPreference -Value 42
            $result | Should -BeOftype 'String'
            $result | Should -Be '42'
        }
    }

    Context 'Format-SqlScriptVariable' {

        It 'Should properly format a string with 3 variables' {
            $parameteres = @{
                Variable      = 'TraceFilePath={0} MaxRollOverFileCount={1} MaxTraceFileSize={2}'
                VariableValue = 'c:\trace\log,5,500'
            }
            $functionResult = Format-SqlScriptVariable @parameteres
            $compareResult  = Compare-Object -ReferenceObject $functionResult -DifferenceObject @('TraceFilePath=c:\trace\log','MaxRollOverFileCount=5','MaxTraceFileSize=500')

            $functionResult | Should -BeOfType 'string'
            $compareResult  | Should -Be $null
        }

        It 'Should properly format a value with spaces' {
            $parameters = @{
                Variable      = 'TraceFilePath={0}'
                VariableValue = 'C:\Program Files\Microsoft SQL Server\MSSQL11.SMA\MSSQL\Log'
            }

            $functionResult = Format-SqlScriptVariable @parameters

            $functionResult | Should -BeOfType 'string'
            $functionResult | Should -Be $($parameters.Variable -f $parameters.VariableValue)
        }
    }
}
