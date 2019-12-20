#region Header
using module .\..\..\..\Module\STIG\Convert\Convert.Main.psm1
. $PSScriptRoot\..\..\..\Module\STIG\Functions.XccdfXml.ps1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Functions

    Describe 'Split-StigXccdf' {

        $sampleXccdfFileName = 'U_Windows_Server_2016{0}_STIG_V1R1_Manual-xccdf.xml'
        $sampleXccdfId = 'Windows_Server_2016{0}_STIG'
        $sampleXccdfPath = "$TestDrive\$sampleXccdfFileName" -f ''
        (Get-TestStigRule -XccdfId ($sampleXccdfId -f '')).Save($sampleXccdfPath)
        Split-StigXccdf -Path $sampleXccdfPath

        Context 'Member Server' {
            $sampleXccdfSplitPath = "$TestDrive\$sampleXccdfFileName" -f '_MS'
            It 'Should create an MS STIG file' {
                Test-Path -Path $sampleXccdfSplitPath | Should Be $true
            }

            It 'Should have MS in the benchmark ID' {
                [xml] $sampleXccdfSplitContent = Get-Content $sampleXccdfSplitPath -Encoding UTF8 -Raw
                $sampleXccdfSplitContent.Benchmark.id | Should Be ($sampleXccdfId -f '_MS')
            }
        }

        Context 'Domain Controller' {
            $sampleXccdfSplitPath = "$TestDrive\$sampleXccdfFileName" -f '_DC'
            It 'Should create an DC STIG file' {
                Test-Path -Path $sampleXccdfSplitPath | Should Be $true
            }
            It 'Should have DC in the benchmark ID' {
                [xml] $sampleXccdfSplitContent = Get-Content $sampleXccdfSplitPath -Encoding UTF8 -Raw
                $sampleXccdfSplitContent.Benchmark.id | Should Be ($sampleXccdfId -f '_DC')
            }
        }
    }
    Describe 'Get-StigVersionNumber' {
        $majorVersionNumber = '1'
        $minorVersionNumber = '5'
        $sampleXccdf = Get-TestStigRule -XccdfVersion $majorVersionNumber `
            -XccdfRelease "Release: $minorVersionNumber Benchmark Date: 01 Jan 1901"

        It 'Should extract the version number from the xccdf' {
            Get-StigVersionNumber -StigDetails $sampleXccdf |
                Should Be "$majorVersionNumber.$minorVersionNumber"
        }
    }
    Describe 'Get-PowerStigFileList' {
        $majorVersionNumber = '1'
        $minorVersionNumber = '5'
        $sampleXccdf = Get-TestStigRule -XccdfVersion $majorVersionNumber `
            -XccdfRelease "Release: $minorVersionNumber Benchmark Date: 01 Jan 1901" `
            -XccdfId "Windows_2012_DC_STIG"
        $expectedName = "WindowsServer-2012R2-DC-$majorVersionNumber.$minorVersionNumber.xml"
        Context 'No Destination supplied' {

            $powerStigFileList = Get-PowerStigFileList -StigDetails $sampleXccdf

            It 'Should return a fileInfo Object' {
                $powerStigFileList.Settings.GetType().ToString() | Should Be 'System.IO.FileInfo'
            }
            It 'Should return the file name' {
                $powerStigFileList.Settings.Name | Should Be $expectedName
            }
            It 'Should return the full path' {
                $powerStigFileList.Settings.FullName | Should Be "$script:moduleRoot\StigData\Processed\$expectedName"
            }
        }

        <#{TODO}#> <# The Resolve-Path mock isn't working in AppVeyor for some reason
        Context 'Destination supplied' {
            Mock -CommandName Resolve-Path -MockWith {return 'C:\Test\Path'}
            $powerStigFileList = Get-PowerStigFileList -StigDetails $sampleXccdf -Destination '.\Path'

            It 'Should return the full path of the supplied destination' {
                $powerStigFileList.Settings.FullName | Should Be "C:\Test\Path\$expectedName"
            }
        }
        #>
    }
    Describe 'Split-BenchmarkId' {
        $sampleStrings = [ordered]@{
            'SQLServer' = @(
                @{
                    'id' = 'Microsoft_SQL_Server_2012_Database__Security_Technical_Implementation_Guide_NewBenchmark'
                    'Technology' = 'SQLServer'
                    'TechnologyVersion' = '2012'
                    'TechnologyRole' = 'Database'
                    'Path' = 'Database_STIG'
                },
                @{
                    'id' = 'Microsoft_SQL_Server_2012_Database_Instance_Security_Technical_Implementation_Guide'
                    'Technology' = 'SQLServer'
                    'TechnologyVersion' = '2012'
                    'TechnologyRole' = 'Instance'
                    'Path' = 'Instance_STIG'
                },
                @{
                    'id' = 'Microsoft_SQL_Server_2016_Database__Security_Technical_Implementation_Guide_NewBenchmark'
                    'Technology' = 'SQLServer'
                    'TechnologyVersion' = '2016'
                    'TechnologyRole' = 'Database'
                    'Path' = 'Database_STIG'
                },
                @{
                    'id' = 'Microsoft_SQL_Server_2016_Database_Instance_Security_Technical_Implementation_Guide'
                    'Technology' = 'SQLServer'
                    'TechnologyVersion' = '2016'
                    'TechnologyRole' = 'Instance'
                    'Path' = 'Instance_STIG'
                }
            )
            'Firewall' = @(
                @{
                    'id' = 'Windows_Firewall'
                    'Technology' = 'WindowsFirewall'
                    'TechnologyVersion' = 'All'
                    'TechnologyRole' = $null
                }
            )
            'DNS' = @(
                @{
                    'id' = 'Microsoft_Windows_2012_Server_Domain_Name_System_STIG'
                    'Technology' = 'WindowsServer'
                    'TechnologyVersion' = '2012R2'
                    'TechnologyRole' = 'DNS'
                }
            )
            'Windows' = @(
                @{
                    'id' = 'Windows_2012_DC_STIG'
                    'Technology' = 'WindowsServer'
                    'TechnologyVersion' = '2012R2'
                    'TechnologyRole' = 'DC'
                },
                @{
                    'id' = 'Windows_2012_MS_STIG'
                    'Technology' = 'WindowsServer'
                    'TechnologyVersion' = '2012R2'
                    'TechnologyRole' = 'MS'
                },
                @{
                    'id' = 'Windows_Server_2016_DC_STIG'
                    'Technology' = 'WindowsServer'
                    'TechnologyVersion' = '2016'
                    'TechnologyRole' = 'DC'
                },
                @{
                    'id' = 'Windows_Server_2016_MS_STIG'
                    'Technology' = 'WindowsServer'
                    'TechnologyVersion' = '2016'
                    'TechnologyRole' = 'MS'
                },
                @{
                    'id' = 'Windows_10'
                    'Technology' = 'WindowsClient'
                    'TechnologyVersion' = '10'
                    'TechnologyRole' = $null
                }
            )
            'Active_Directory' = @(
                @{
                    'id' = 'Active_Directory_Domain'
                    'Technology' = 'ActiveDirectory'
                    'TechnologyVersion' = 'All'
                    'TechnologyRole' = 'Domain'
                },
                @{
                    'id' = 'Active_Directory_Forest'
                    'Technology' = 'ActiveDirectory'
                    'TechnologyVersion' = 'All'
                    'TechnologyRole' = 'Forest'
                }
            )
            'IE' = @(
                @{
                    'id' = 'IE_11_STIG'
                    'Technology' = 'InternetExplorer'
                    'TechnologyVersion' = '11'
                    'TechnologyRole' = $null
                }
            )
            'Outlook2013' = @(
                @{
                    'id' = 'Microsoft_Outlook_2013'
                    'Technology' = 'Office'
                    'TechnologyVersion' = 'Outlook2013'
                    'TechnologyRole' = $null
                }
            )
            'PowerPoint2013' = @(
                @{
                    'id'                = 'Microsoft_PowerPoint_2013'
                    'Technology'        = 'Office'
                    'TechnologyVersion' = 'PowerPoint2013'
                    'TechnologyRole'    = $null
                }
            )
            'Excel2013' = @(
                @{
                    'id'                = 'Microsoft_Excel_2013'
                    'Technology'        = 'Office'
                    'TechnologyVersion' = 'Excel2013'
                    'TechnologyRole'    = $null
                }
            )
            'Word2013' = @(
                @{
                    'id'                = 'Microsoft_Word_2013'
                    'Technology'        = 'Office'
                    'TechnologyVersion' = 'Word2013'
                    'TechnologyRole'    = $null
                }
            )
            'DotNet4' = @(
                @{
                    'id' = 'MS_Dot_Net_Framework'
                    'Technology'        = 'DotNetFramework'
                    'TechnologyVersion' = '4'
                    'TechnologyRole'    = $null
                }
            )
        }
        foreach ($sampleString in $sampleStrings.GetEnumerator())
        {
            Context "$($sampleString.Key)" {

                foreach ($sample in $sampleString.value)
                {
                    Context "$($sample.Id)" {
                        # The metadata in the SQL STIG doesn't specifiy database or instance so we get that from the file name of the xccdf.
                        $benchmarkId = Split-BenchmarkId -Id $sample.Id -FilePath $sample.Path
                        It "Should return $($sample.Technology) as the Technology property" {
                            $benchmarkId.Technology | Should Be $sample.Technology
                        }
                        It "Should return $($sample.TechnologyVersion) as the TechnologyVersion property" {
                            $benchmarkId.TechnologyVersion | Should Be $sample.TechnologyVersion
                        }

                        It "Should return $($sample.TechnologyRole) as the TechnologyRole property" {

                            $benchmarkId.TechnologyRole | Should Be $sample.TechnologyRole
                        }
                    }
                }
            }
        }
    }
    Describe 'Conversion Status' {
        It 'Should not contain conversionstatus="fail" in any processed STIG' {
            $selectStringResults = Select-String -Pattern 'conversionstatus="fail"' -Path "$PSScriptRoot\..\..\..\StigData\Processed\*.xml"
            $selectStringResults | Should Be $null
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
