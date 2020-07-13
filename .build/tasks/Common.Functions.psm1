$supportFileList = Get-ChildItem -Path $PSScriptRoot -Filter '*.Data.ps1'
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}

function Convert-HashtableToString
{
    param
    (
        [Parameter()]
        [System.Collections.Hashtable]
        $Hashtable
    )
    $values = @()
    foreach ($pair in $Hashtable.GetEnumerator())
    {
        if ($pair.Value -is [System.Array])
        {
            $str = "$($pair.Key)=($($pair.Value -join ","))"
        }
        elseif ($pair.Value -is [System.Collections.Hashtable])
        {
            $str = "$($pair.Key)={$(Convert-HashtableToString -Hashtable $pair.Value)}"
        }
        else
        {
            $str = "$($pair.Key)=$($pair.Value)"
        }
        $values += $str
    }

    [array]::Sort($values)
    return ($values -join "; ")
}

function Get-CodeCoverageThreshold
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.String]
        $CodeCoverageThreshold,

        [Parameter()]
        [PSObject]
        $BuildInfo
    )

    # If no codeCoverageThreshold configured at runtime, look for BuildInfo settings.
    if ($CodeCoverageThreshold -eq '')
    {
        if ($BuildInfo.ContainsKey('Pester') -and $BuildInfo.Pester.ContainsKey('CodeCoverageThreshold'))
        {
            $CodeCoverageThreshold = $BuildInfo.Pester.CodeCoverageThreshold
            Write-Debug -Message "Loaded Code Coverage Threshold from Config file: $CodeCoverageThreshold %."
        }
        else
        {
            $CodeCoverageThreshold = 0
            Write-Debug -Message "No code coverage threshold value found (param nor config), using the default value."
        }
    }
    else
    {
        $CodeCoverageThreshold = [int] $CodeCoverageThreshold
        Write-Debug -Message "Loading CodeCoverage Threshold from Parameter ($CodeCoverageThreshold %)."
    }

    return $CodeCoverageThreshold
}

function Get-ModuleVersion
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.String]
        $OutputDirectory,

        [Parameter()]
        [System.String]
        $ProjectName,

        [Parameter()]
        [System.String]
        $ModuleVersion
    )

    if ([System.String]::IsNullOrEmpty($ModuleVersion))
    {
        $moduleInfo = Import-PowerShellDataFile "$OutputDirectory/$ProjectName/*/$ProjectName.psd1" -ErrorAction 'Stop'

        if ($preReleaseTag = $moduleInfo.PrivateData.PSData.Prerelease)
        {
            $moduleVersion = $moduleInfo.ModuleVersion + "-" + $preReleaseTag
        }
        else
        {
            $moduleVersion = $moduleInfo.ModuleVersion
        }
    }
    else
    {
        <#
            This handles a previous version of the module that suggested to pass
            a version string with metadata in the CI pipeline that can look like
            this: 1.15.0-pr0224-0022+Sha.47ae45eb2cfed02b249f239a7c55e5c71b26ab76.Date.2020-01-07
        #>
        $moduleVersion = ($moduleVersion -split '\+', 2)[0]
    }

    return $moduleVersion
}

function Get-OperatingSystemShortName
{
    [CmdletBinding()]
    param ()

    $osShortName = if ($isWindows -or $PSVersionTable.PSVersion.Major -le 5)
    {
        'Windows'
    }
    elseif ($isMacOS)
    {
        'MacOS'
    }
    else
    {
        'Linux'
    }

    return $osShortName
}

function Get-PesterOutputFileFileName
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProjectName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleVersion,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OsShortName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PowerShellVersion
    )

    return '{0}_v{1}.{2}.{3}.xml' -f $ProjectName, $ModuleVersion, $OsShortName, $PowerShellVersion
}

function Get-CodeCoverageOutputFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [PSObject]
        $BuildInfo,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PesterOutputFolder
    )

    if ($BuildInfo.ContainsKey('Pester') -and $BuildInfo.Pester.ContainsKey('CodeCoverageOutputFile'))
    {
        $codeCoverageOutputFile = $executioncontext.invokecommand.expandstring($BuildInfo.Pester.CodeCoverageOutputFile)

        if (-not (Split-Path -IsAbsolute $codeCoverageOutputFile))
        {
            $codeCoverageOutputFile = Join-Path -Path $PesterOutputFolder -ChildPath $codeCoverageOutputFile

            Write-Debug -Message "Absolute path to code coverage output file is $codeCoverageOutputFile."
        }
    }
    else
    {
        $codeCoverageOutputFile = $null
    }

    return $codeCoverageOutputFile
}

function Get-CodeCoverageOutputFileEncoding
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [PSObject]
        $BuildInfo
    )

    if ($BuildInfo.ContainsKey('Pester') -and $BuildInfo.Pester.ContainsKey('CodeCoverageOutputFileEncoding'))
    {
        $codeCoverageOutputFileEncoding = $BuildInfo.Pester.CodeCoverageOutputFileEncoding
    }
    else
    {
        $codeCoverageOutputFileEncoding = $null
    }

    return $codeCoverageOutputFileEncoding
}

function Merge-JaCoCoReports
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]
        $OriginalDocument,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]
        $MergeDocument
    )

    foreach ($mPackage in $MergeDocument.report.package)
    {
        Write-Verbose "  Processing package: $($mPackage.Name)"
        $oPackage = $OriginalDocument.report.package | Where-Object { $_.Name -eq $mPackage.Name }

        foreach ($mSourcefile in $mPackage.sourcefile)
        {
            Write-Verbose "    Processing sourcefile: $($mSourcefile.Name)"
            if ($null -ne $oPackage)
            {
                foreach ($mPackageLine in $mSourcefile.line)
                {
                    $oSourcefile = $oPackage.sourcefile | Where-Object { $_.name -eq $mSourcefile.name }
                    $oPackageLine = $oSourcefile.line | Where-Object { $_.nr -eq $mPackageLine.nr }

                    if ($null -eq $oPackageLine)
                    {
                        # Missed line in origin, covered in merge
                        Write-Verbose "      Adding line: $($mPackageLine.nr)"
                        $null = $oPackage.sourcefile.AppendChild($oPackage.sourcefile.OwnerDocument.ImportNode($mPackageLine, $true))
                        continue
                    }

                    if (($oPackageLine.ci -eq 0) -and ($oPackageLine.mi -ne 0) -and `
                        ($mPackageLine.ci -ne 0) -and ($mPackageLine.mi -eq 0))
                    {
                        # Missed line in origin, covered in merge
                        Write-Verbose "      Updating missed line: $($mPackageLine.nr)"
                        $oPackageLine.ci = $mPackageLine.ci
                        $oPackageLine.mi = $mPackageLine.mi
                        continue
                    }

                    if ($oPackageLine.ci -lt $mPackageLine.ci)
                    {
                        # Missed line in origin, covered in merge
                        Write-Verbose "      Updating line: $($mPackageLine.nr)"
                        $oPackageLine.ci = $mPackageLine.ci
                        $oPackageLine.mi = $mPackageLine.mi
                        continue
                    }
                }
            }
            else
            {
                # New package, does not exist in origin. Add package.
                Write-Verbose "    Package '$($mPackage.Name)' does not exist in original file. Adding..."
                foreach ($xmlElement in $OriginalDocument.report)
                {
                    if ($xmlElement -is [System.Xml.XmlElement])
                    {
                        $null = $xmlElement.AppendChild($OriginalDocument.report.OwnerDocument.ImportNode($mPackage, $true))
                        break
                    }
                }
            }
        }
    }

    return $OriginalDocument
}

function Update-JaCoCoStatistics
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]
        $Document
    )

    Write-Verbose "Start updating statistics!"

    $totalInstructionCovered = 0
    $totalInstructionMissed = 0
    $totalLineCovered = 0
    $totalLineMissed = 0
    $totalMethodCovered = 0
    $totalMethodMissed = 0
    $totalClassCovered = 0
    $totalClassMissed = 0

    foreach ($oPackage in $Document.report.package)
    {
        Write-Verbose "Processing package $($oPackage.name)"

        $packageInstructionCovered = 0
        $packageInstructionMissed = 0
        $packageLineCovered = 0
        $packageLineMissed = 0
        $packageMethodCovered = 0
        $packageMethodMissed = 0
        $packageClassCovered = 0
        $packageClassMissed = 0

        foreach ($oPackageClass in $oPackage.class)
        {
            $classInstructionCovered = 0
            $classInstructionMissed = 0
            $classLineCovered = 0
            $classLineMissed = 0
            $classMethodCovered = 0
            $classMethodMissed = 0

            Write-Verbose "  Processing sourcefile $($oPackageClass.sourcefilename)"
            $oPackageSourcefile = $oPackage.sourcefile | Where-Object -FilterScript { $_.Name -eq $oPackageClass.sourcefilename }

            $oneMethodProcessed = $false
            for ($i = 0; $i -lt ([array]($oPackageClass.method)).Count; $i++)
            {
                $methodInstructionCovered = 0
                $methodInstructionMissed = 0
                $methodLineCovered = 0
                $methodLineMissed = 0
                $methodCovered = 0
                $methodMissed = 0

                $currentMethod = [array]$oPackageClass.method
                $start = $currentMethod[$i].line
                if ($i -ne ($currentMethod.Count - 1))
                {
                    $end   = $currentMethod[$i+1].Line
                    Write-Verbose "    Processing method: $($currentMethod[$i].Name)"
                    [array]$coll = $oPackageSourcefile.line | Where-Object {
                        [int]$_.nr -ge $start -and [int]$_.nr -lt $end
                    }

                    foreach ($line in $coll)
                    {
                        $methodInstructionCovered += $line.ci
                        $methodInstructionMissed += $line.mi
                    }
                    [array]$cov = $coll | Where-Object -FilterScript { $_.ci -ne "0" }
                    $methodLineCovered = $cov.Count
                    [array]$mis = $coll | Where-Object -FilterScript { $_.ci -eq "0" }
                    $methodLineMissed = $mis.Count
                }
                else
                {
                    Write-Verbose "    Processing method: $($currentMethod[$i].Name)"
                    [array]$coll = $oPackageSourcefile.line | Where-Object {
                        [int]$_.nr -ge $start
                    }

                    foreach ($line in $coll)
                    {
                        $methodInstructionCovered += $line.ci
                        $methodInstructionMissed += $line.mi
                    }

                    [array]$cov = $coll | Where-Object -FilterScript { $_.ci -ne "0" }
                    $methodLineCovered = $cov.Count
                    [array]$mis = $coll | Where-Object -FilterScript { $_.ci -eq "0" }
                    $methodLineMissed = $mis.Count
                }

                $classInstructionCovered += $methodInstructionCovered
                $classInstructionMissed += $methodInstructionMissed
                $classLineCovered += $methodLineCovered
                $classLineMissed += $methodLineMissed
                if ($methodInstructionCovered -ne 0)
                {
                    $methodCovered = 1
                    $methodMissed = 0
                    $classMethodCovered++
                }
                else
                {
                    $methodCovered = 0
                    $methodMissed = 1
                    $classMethodMissed++
                }
                if ($currentMethod[$i].Name -ne '<script>' -and $methodMissed -eq 0)
                {
                    $oneMethodProcessed = $true
                }

                # Update Method stats
                $counterInstruction = $currentMethod[$i].counter | Where-Object { $_.type -eq 'INSTRUCTION' }
                $counterInstruction.covered = [string]$methodInstructionCovered
                $counterInstruction.missed = [string]$methodInstructionMissed

                $counterLine = $currentMethod[$i].counter | Where-Object { $_.type -eq 'LINE' }
                $counterLine.covered = [string]$methodLineCovered
                $counterLine.missed = [string]$methodLineMissed

                $counterMethod = $currentMethod[$i].counter | Where-Object { $_.type -eq 'METHOD' }
                $counterMethod.covered = [string]$methodCovered
                $counterMethod.missed = [string]$methodMissed


                Write-Verbose "      Method Instruction Covered : $methodInstructionCovered"
                Write-Verbose "      Method Instruction Missed  : $methodInstructionMissed"
                Write-Verbose "      Method Line Covered        : $methodLineCovered"
                Write-Verbose "      Method Line Missed         : $methodLineMissed"
                Write-Verbose "      Method Covered             : $methodCovered"
                Write-Verbose "      Method Missed              : $methodMissed"
            }

            $packageInstructionCovered += $classInstructionCovered
            $packageInstructionMissed += $classInstructionMissed
            $packageLineCovered += $classLineCovered
            $packageLineMissed += $classLineMissed
            $packageMethodCovered += $classMethodCovered
            $packageMethodMissed += $classMethodMissed
            if ($oneMethodProcessed -eq $true)
            {
                $packageClassCovered++
                $classClassCovered = 1
                $classClassMissed = 0
            }
            else
            {
                $classClassCovered = 0
                $classClassMissed = 1
            }

            # Update Class stats
            $counterInstruction = $oPackageClass.counter | Where-Object { $_.type -eq 'INSTRUCTION' }
            $counterInstruction.covered = [string]$classInstructionCovered
            $counterInstruction.missed = [string]$classInstructionMissed

            $counterLine = $oPackageClass.counter | Where-Object { $_.type -eq 'LINE' }
            $counterLine.covered = [string]$classLineCovered
            $counterLine.missed = [string]$classLineMissed

            $counterMethod = $oPackageClass.counter | Where-Object { $_.type -eq 'METHOD' }
            $counterMethod.covered = [string]$classMethodCovered
            $counterMethod.missed = [string]$classMethodMissed

            $counterMethod = $oPackageClass.counter | Where-Object { $_.type -eq 'CLASS' }
            $counterMethod.covered = [string]$classClassCovered
            $counterMethod.missed = [string]$classClassMissed

            # Update Sourcefile stats
            $counterInstruction = $oPackageSourcefile.counter | Where-Object { $_.type -eq 'INSTRUCTION' }
            $counterInstruction.covered = [string]$classInstructionCovered
            $counterInstruction.missed = [string]$classInstructionMissed

            $counterLine = $oPackageSourcefile.counter | Where-Object { $_.type -eq 'LINE' }
            $counterLine.covered = [string]$classLineCovered
            $counterLine.missed = [string]$classLineMissed

            $counterMethod = $oPackageSourcefile.counter | Where-Object { $_.type -eq 'METHOD' }
            $counterMethod.covered = [string]$classMethodCovered
            $counterMethod.missed = [string]$classMethodMissed

            $counterMethod = $oPackageSourcefile.counter | Where-Object { $_.type -eq 'CLASS' }
            $counterMethod.covered = [string]$classClassCovered
            $counterMethod.missed = [string]$classClassMissed

            Write-Verbose "      Class Instruction Covered  : $classInstructionCovered"
            Write-Verbose "      Class Instruction Missed   : $classInstructionMissed"
            Write-Verbose "      Class Line Covered         : $classLineCovered"
            Write-Verbose "      Class Line Missed          : $classLineMissed"
            Write-Verbose "      Class Method Covered       : $classMethodCovered"
            Write-Verbose "      Class Method Missed        : $classMethodMissed"
        }
        $totalInstructionCovered += $packageInstructionCovered
        $totalInstructionMissed += $packageInstructionMissed
        $totalLineCovered += $packageLineCovered
        $totalLineMissed += $packageLineMissed
        $totalMethodCovered += $packageMethodCovered
        $totalMethodMissed += $packageMethodMissed
        $totalClassCovered += $packageClassCovered
        $totalClassMissed += $packageClassMissed

        # Update Package stats
        $counterInstruction = $oPackage.counter | Where-Object { $_.type -eq 'INSTRUCTION' }
        $counterInstruction.covered = [string]$packageInstructionCovered
        $counterInstruction.missed = [string]$packageInstructionMissed

        $counterLine = $oPackage.counter | Where-Object { $_.type -eq 'LINE' }
        $counterLine.covered = [string]$packageLineCovered
        $counterLine.missed = [string]$packageLineMissed

        $counterMethod = $oPackage.counter | Where-Object { $_.type -eq 'METHOD' }
        $counterMethod.covered = [string]$packageMethodCovered
        $counterMethod.missed = [string]$packageMethodMissed

        $counterClass = $oPackage.counter | Where-Object { $_.type -eq 'CLASS' }
        $counterClass.covered = [string]$packageClassCovered
        $counterClass.missed = [string]$packageClassMissed

        Write-Verbose "  Package Instruction Covered: $packageInstructionCovered"
        Write-Verbose "  Package Instruction Missed : $packageInstructionMissed"
        Write-Verbose "  Package Line Covered       : $packageLineCovered"
        Write-Verbose "  Package Line Missed        : $packageLineMissed"
        Write-Verbose "  Package Method Covered     : $packageMethodCovered"
        Write-Verbose "  Package Method Missed      : $packageMethodMissed"
        Write-Verbose "  Package Class Covered      : $packageClassCovered"
        Write-Verbose "  Package Class Missed       : $packageClassMissed"
    }

    #Update Total stats
    $counterInstruction = $Document.report.counter | Where-Object { $_.type -eq 'INSTRUCTION' }
    $counterInstruction.covered = [string]$totalInstructionCovered
    $counterInstruction.missed = [string]$totalInstructionMissed

    $counterLine = $Document.report.counter | Where-Object { $_.type -eq 'LINE' }
    $counterLine.covered = [string]$totalLineCovered
    $counterLine.missed = [string]$totalLineMissed

    $counterMethod = $Document.report.counter | Where-Object { $_.type -eq 'METHOD' }
    $counterMethod.covered = [string]$totalMethodCovered
    $counterMethod.missed = [string]$totalMethodMissed

    $counterClass = $Document.report.counter | Where-Object { $_.type -eq 'CLASS' }
    $counterClass.covered = [string]$totalClassCovered
    $counterClass.missed = [string]$totalClassMissed

    Write-Verbose "----------------------------------------"
    Write-Verbose " Totals"
    Write-Verbose "----------------------------------------"
    Write-Verbose "  Total Instruction Covered : $totalInstructionCovered"
    Write-Verbose "  Total Instruction Missed  : $totalInstructionMissed"
    Write-Verbose "  Total Line Covered        : $totalLineCovered"
    Write-Verbose "  Total Line Missed         : $totalLineMissed"
    Write-Verbose "  Total Method Covered      : $totalMethodCovered"
    Write-Verbose "  Total Method Missed       : $totalMethodMissed"
    Write-Verbose "  Total Class Covered       : $totalClassCovered"
    Write-Verbose "  Total Class Missed        : $totalClassMissed"
    Write-Verbose "----------------------------------------"

    Write-Verbose "Completed merging files and updating statistics!"

    return $Document
}

function New-NuspecFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $DestinationPath,

        [Parameter(Mandatory = $true)]
        [String]
        $ModuleManifestPath
    )

    # https://docs.microsoft.com/en-us/nuget/reference/nuspec

    $moduleManifest = Import-PowerShellDataFile -Path $ModuleManifestPath

    $requiredModuleStringBuilder = New-Object -TypeName System.Text.StringBuilder
    foreach ($dependency in $moduleManifest.RequiredModules)
    {
        $requiredModuleContents = "      <dependency id='{0}' version='[{1}]' />" -f $dependency.ModuleName, $dependency.ModuleVersion
        [void] $requiredModuleStringBuilder.AppendLine($requiredModuleContents)
    }

    $nuspecFileContent = $nuspecContents -f
        $moduleManifest['ModuleVersion'],
        $moduleManifest['Author'],
        $moduleManifest['CompanyName'],
        $moduleManifest['PrivateData']['PsData']['LicenseUri'],
        $moduleManifest['PrivateData']['PsData']['ProjectUri'],
        $moduleManifest['Description'],
        $moduleManifest['PrivateData']['PsData']['ReleaseNotes'],
        $moduleManifest['Copyright'],
        $(Get-Date).Year,
        $($moduleManifest['PrivateData']['PsData']['Tags'] -join ' '),
        $($requiredModuleStringBuilder.ToString()),
        $moduleManifest['ModuleVersion']

    if (-not (Test-Path -Path $DestinationPath))
    {
        $null = New-Item -Path $DestinationPath -ItemType 'Directory'
    }

    $packageName = (Split-Path -Path $ModuleManifestPath -Leaf) -replace '.psd1'
    $nuspecFilePath = Join-Path -Path $DestinationPath -ChildPath "$packageName.nuspec"
    $nuspecFile = New-Item -Path $nuspecFilePath -ItemType 'File' -Force
    $null = Set-Content -Path $nuspecFilePath -Value $nuspecFileContent
    return $nuspecFile.FullName
}

Export-ModuleMember -Function @(
    'Convert-HashtableToString'
    'Get-CodeCoverageThreshold'
    'Get-ModuleVersion'
    'Get-OperatingSystemShortName'
    'Get-PesterOutputFileFileName'
    'Get-CodeCoverageOutputFile'
    'Get-CodeCoverageOutputFileEncoding'
    'Merge-JaCoCoReports'
    'Update-JaCoCoStatistics'
    'New-NuspecFile'
)
