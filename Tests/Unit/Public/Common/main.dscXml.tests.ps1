# Build the path to the system under test
[string] $sut = $MyInvocation.MyCommand.Path -replace '\\tests\\','\src\' `
                                             -replace '\.tests','' `
                                             -replace '\\unit\\','\'
# load the system under test
. $sut

# Import the base benchmark xml string data.
$BaseFileContent = Get-Content -Path "$PSScriptRoot\..\..\..\sampleXccdf.xml.txt" -Encoding UTF8
Describe "ConvertTo-DscStigXml" {

    It "Should have a synopsis in the help" {
        [string] $Synopsis = (Get-Help ConvertTo-DscStigXml).Synopsis
        $Synopsis | Should Not BeNullOrEmpty
    }

    It 'Should throw an error when given bad xml' {
        #ConvertTo-DscStigXml -   
    }
}
