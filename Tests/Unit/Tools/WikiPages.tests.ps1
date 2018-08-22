$unitTestRoot = Split-Path -Path $PSScriptRoot -Parent
. "$unitTestRoot\.tests.header.ps1"
try
{
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
