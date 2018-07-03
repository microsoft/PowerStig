# Build the path to the system under test
[string] $sut = $MyInvocation.MyCommand.Path -replace '\\tests\\','\src\' `
                                             -replace '\.tests','' `
                                             -replace '\\unit\\','\'
# load the system under test
. $sut
# Import the base benchmark xml string data.
$BaseFileContent = Get-Content -Path "$PSScriptRoot\..\..\..\sampleXccdf.xml.txt" -Encoding UTF8

function ConvertFrom-StigXccdf {}
function Get-RuleTypeList {}
Describe "Get-ConversionReport" {
    
    It "Should have a synopsis in the help" {
        [string] $Synopsis = (Get-Help Get-ConversionReport).Synopsis
        $Synopsis | Should Not BeNullOrEmpty
    }
    
    $sampleConvertedXccdf = @(
        @{
            RuleType = "RegistryRule"
            id       = "V-1000"
        },
        @{
            RuleType = "DocumentRule"
            id       = "V-1001"
        }
    )
    Mock -CommandName ConvertFrom-StigXccdf -MockWith {return $sampleConvertedXccdf}
    Mock -CommandName Get-RuleTypeList -MockWith {@('DocumentRule', 'RegistryRule')} 

    $TestFile = "TestDrive:\TextData.xml"
    $BaseFileContent -f $title, '', '', '' | Out-File -FilePath $TestFile

    It 'Should return an array' {
        $ConversionReportType = (Get-ConversionReport -Path $TestFile).GetType().BaseType.Name 
        $ConversionReportType | Should Be "Array"   
    }

    It 'Should contain a RuleType member' {
        $ReportItemType = (Get-ConversionReport -Path $TestFile).Type
        $ReportItemType | Should Not BeNullOrEmpty   
    }

    It 'Should contain a Count member' {
        $ReportItemCount = (Get-ConversionReport -Path $TestFile).Count
        $ReportItemCount | Should Not BeNullOrEmpty
    }

    It 'Should contain a Errors member' {
        $ReportItemError = (Get-ConversionReport -Path $TestFile).Errors
        $ReportItemError | Should Not BeNullOrEmpty   
    }
}
