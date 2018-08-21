$script:ModuleName = 'WikiPages'
$script:moduleRootPath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent

try
{
    Import-Module -Name (Join-Path -Path $script:moduleRootPath -ChildPath (
            Join-Path -Path $script:ModuleName -ChildPath "$($script:ModuleName).psm1")) -Force

    InModuleScope $script:ModuleName {

        Describe 'Format-HelpString' -Tag 'tools' {

            Context 'Multi-Line' {
                It "Should Format the help string" {
                    $testString = @{
                        sample = @(
                            'This is a multi line string. '
                            'There are multiple lines.') -Join "`n"
                        result = @(
                            'This is a multi line string.'
                            'There are multiple lines.') -Join "`n"
                    }
                    Format-HelpString -String $testString.sample |
                    Should Be $testString.result
                }
                It "Should return full sentences on each line." {
                    $testString = @{
                        sample = @(
                            'This is a multi line'
                            'string. That has a period.') -Join "`n"
                        result = @(
                            'This is a multi line string.'
                            'That has a period.') -Join "`n"
                    }

                    Format-HelpString -String $testString.sample |
                    Should Be $testString.result
                }
            }

            Context 'Single-Line' {

                It "Should return multiple sentences on a singe line." {
                    $testString = @{
                        sample = @(
                            'This is a multi line string. '
                            'There are multiple lines.') -Join "`n"
                        result = @(
                            'This is a multi line string.'
                            'There are multiple lines.') -Join " "
                    }
                    Format-HelpString -String $testString.sample -SingleLine |
                    Should Be $testString.result
                }

            }

        }
    }
}
finally
{

}
