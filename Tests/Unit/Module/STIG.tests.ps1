#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
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
                    'Technology' = 'WindowsDnsServer'
                    'TechnologyVersion' = '2012R2'
                    'TechnologyRole' = $null
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
            $processedStigDataPath = Join-Path -Path $script:moduleRoot -ChildPath 'StigData\Processed\*.xml'
            $selectStringResults = Select-String -Pattern 'conversionstatus="fail"' -Path $processedStigDataPath
            $selectStringResults | Should Be $null
        }
    }

    Describe 'Stale Log File Entries' {
        It 'Rule IDs that are not present in archived STIG should not exist in associated log file' {

            $archiveStigDataPath = Join-Path -Path $script:moduleRoot -ChildPath 'StigData\Archive'
            $idFound = $false

            # Input log file
            $logItems = (Get-ChildItem -Path $archiveStigDataPath -Recurse -Include "*.log").FullName

            # Match log file with xml
            foreach ($logItem in $logItems)
            {
                $archiveIds =  @()
                $logIds = @()

                # Get xml name
                $xmlName = $logItem.replace(".log",".xml")

                # Get Log rule ids
                $logIds = (Get-Content -Path $logItem | Select-String -Pattern "(V-).\d+").Matches.Value

                # Get Archive rule ids
                [xml] $archiveStig = Get-Content -Path $xmlName
                [string[]] $archiveIds = $archiveStig.Benchmark.Group.id

                foreach ($id in $logIds)
                {
                    if ($archiveIds -notcontains $id)
                    {
                        $idFound = $true
                        Write-Host "Rule $id does not exist in archived STIG folder"
                    }
                }
            }

            $idFound | Should -Be $false
        }
    }

    Describe 'N-2 STIGs exist in repo' {
        It 'PowerSTIG should only host N-1 versions of STIGs' {

            $archiveStigDataPath = Join-Path -Path $script:moduleRoot -ChildPath 'StigData\Archive'
            $processedStigDataPath = Join-Path -Path $script:moduleRoot -ChildPath 'StigData\Processed'
            $extraVersion = $false

            # Get archive STIGs
            $archiveStigs = (Get-ChildItem -Path $archiveStigDataPath -Recurse -Include "*.xml").FullName

            # Get archive STIGs
            $processedStigs = (Get-ChildItem -Path $processedStigDataPath -Recurse -Include "*.xml" -Exclude "*default.xml").FullName

            # Find technology groups in archive folder
            $groupsArchived = ($archiveStigs | Select-String -Pattern "(?<=U_).+(?=_.*_Manual)").Matches.Value | Group-Object

            # Find technology groups in archive folder
            $groupsProcessed = ($processedStigs | Select-String -Pattern "(?<=processed\\).+(?=-.*)").Matches.Value | Group-Object

            foreach ($archived in $groupsArchived)
            {
                if ($archived.count -gt 2)
                {
                    $extraVersion = $true
                    $groupMessage = 'There are too many archive versions {0}, please remove all but N-1 versions' -f $archived.Name
                    Write-Host $groupMessage
                }
            }

            foreach ($processed in $groupsProcessed)
            {
                if ($processed.count -gt 2)
                {
                    $extraVersion = $true
                    $groupMessage = 'There are too many processed versions {0}, please remove all but N-1 versions' -f $processed.Name
                    Write-Host $groupMessage
                }
            }

            $extraVersion | Should -Be $false
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
