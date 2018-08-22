# Load the test helper module.
#$testHelperPath = Join-Path -Path $PSScriptRoot -ChildPath 'TestHelper.psm1'
#Import-Module -Name $testHelperPath -Force

<#
    .SYNOPSIS
        Performs the after tests tasks for the AppVeyor build process.

        This includes:
        1. Optional: Produce and upload Wiki documentation to AppVeyor.
        2. Set version number in Module Manifest to build version
        3. Zip up the module content and produce a checksum file and upload to AppVeyor.
        4. Pack the module into a Nuget Package.
        5. Upload the Nuget Package to AppVeyor.

        Executes Start-CustomAppveyorAfterTestTask if defined in .AppVeyor\CustomAppVeyorTasks.psm1
        in resource module repository.

    .PARAMETER Type
        This controls the additional processes that can be run after testing.
        To produce wiki documentation specify 'Wiki', otherwise leave empty to use
        default value 'Default'.

    .PARAMETER MainModulePath
        This is the relative path of the folder that contains the module manifest.
        If not specified it will default to the root folder of the repository.

    .PARAMETER ResourceModuleName
        Name of the Resource Module being produced.
        If not specified will default to GitHub repository name.

    .PARAMETER Author
        The Author string to insert into the NUSPEC file for the package.
        If not specified will default to 'Microsoft'.

    .PARAMETER Owners
        The Owners string to insert into the NUSPEC file for the package.
        If not specified will default to 'Microsoft'.
#>
function Invoke-PowerStigAppveyorAfterTestTask
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $MainModulePath = $env:APPVEYOR_BUILD_FOLDER,

        [Parameter()]
        [String]
        $ModuleName = (($env:APPVEYOR_REPO_NAME -split '/')[1]),

        [Parameter()]
        [String]
        $Author,

        [Parameter()]
        [String]
        $Owners,

        [Parameter()]
        [String]
        $Tags
    )

    # Convert the Main Module path into an absolute path if it is relative
    if (-not ([System.IO.Path]::IsPathRooted($MainModulePath)))
    {
        $MainModulePath = Join-Path -Path $env:APPVEYOR_BUILD_FOLDER `
            -ChildPath $MainModulePath
    }

    $manifest = Import-PowerShellDataFile -Path "$MainModulePath\$moduleName`.psd1"

    $fileListPath = "$env:APPVEYOR_BUILD_FOLDER\.NuspecFileList.json"
    if (Test-Path -Path $fileListPath )
    {
        $fileList = Get-Content -Path $fileListPath | ConvertFrom-Json
    }

    # Create the Nuspec file for the Nuget Package in the Main Module Folder
    $nuspecPath = Join-Path -Path $MainModulePath -ChildPath "$ModuleName.nuspec"

    $nuspecParams = @{
        PackageName = $ModuleName
        DestinationPath = $MainModulePath
        Version = $env:APPVEYOR_BUILD_VERSION
        Author = $manifest.Author
        Owners = $manifest.CompanyName
        LicenseUrl = $manifest.PrivateData.PSData.LicenseUri
        ProjectUrl = $manifest.PrivateData.PSData.ProjectUri
        PackageDescription = $ModuleName
        Tags = $manifest.PrivateData.PSData.Tags -join ' '
        ReleaseNotes = $manifest.PrivateData.PSData.ReleaseNotes
        FileList = $fileList
        RequiredModules = $manifest.RequiredModules
    }
    New-Nuspec @nuspecParams

    # Create the Nuget Package
    $nugetExePath = (Get-Command nuget).Source

    Start-Process -FilePath $nugetExePath -Wait -ArgumentList @(
        'Pack', $nuspecPath
        '-OutputDirectory', $env:APPVEYOR_BUILD_FOLDER
        '-BasePath', $MainModulePath
    )

    # Push the Nuget Package up to AppVeyor
    $nugetPackageName = Join-Path -Path $env:APPVEYOR_BUILD_FOLDER `
        -ChildPath "$ModuleName.$($env:APPVEYOR_BUILD_VERSION).nupkg"
    Get-ChildItem $nugetPackageName | ForEach-Object -Process {
        Push-AppveyorArtifact -Path $_.FullName -FileName $_.Name
    }

    Write-Info -Message 'After Test Task Complete.'
}


<#
    .SYNOPSIS
        Creates a nuspec file for a nuget package at the specified path.

    .EXAMPLE
        New-Nuspec `
            -PackageName 'TestPackage' `
            -Version '1.0.0.0' `
            -Author 'Microsoft Corporation' `
            -Owners 'Microsoft Corporation' `
            -DestinationPath C:\temp `
            -LicenseUrl 'http://license' `
            -PackageDescription 'Description of the package' `
            -Tags 'tag1 tag2'
#>
function New-Nuspec
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $PackageName,

        [Parameter(Mandatory = $true)]
        [String]
        $Version,

        [Parameter(Mandatory = $true)]
        [String]
        $Author,

        [Parameter(Mandatory = $true)]
        [String]
        $Owners,

        [Parameter(Mandatory = $true)]
        [String]
        $DestinationPath,

        [Parameter(Mandatory = $true)]
        [String]
        $LicenseUrl,

        [Parameter(Mandatory = $true)]
        [String]
        $ProjectUrl,

        [Parameter()]
        [String]
        $IconUrl,

        [Parameter(Mandatory = $true)]
        [String]
        $PackageDescription,

        [Parameter(Mandatory = $true)]
        [String]
        $ReleaseNotes,

        [Parameter()]
        [String]
        $Tags,

        [Parameter()]
        [AllowNull()]
        [pscustomobject]
        $FileList,

        [Parameter()]
        [AllowNull()]
        [pscustomobject]
        $RequiredModules
    )
    # https://docs.microsoft.com/en-us/nuget/reference/nuspec

    $currentYear = (Get-Date).Year

    $nuspecFileContent = New-Object System.Text.StringBuilder
    $null = $nuspecFileContent.AppendLine('<?xml version="1.0" encoding="utf-8"?>')
    $null = $nuspecFileContent.AppendLine('<package xmlns="http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd">')
    $null = $nuspecFileContent.AppendLine('  <metadata>')
    $null = $nuspecFileContent.AppendLine("    <id>$PackageName</id>")
    $null = $nuspecFileContent.AppendLine("    <version>$Version</version>")
    $null = $nuspecFileContent.AppendLine("    <authors>$Author</authors>")
    $null = $nuspecFileContent.AppendLine("    <owners>$Owners</owners>")

    if (-not [String]::IsNullOrEmpty($LicenseUrl))
    {
        $null = $nuspecFileContent.AppendLine("    <licenseUrl>$LicenseUrl</licenseUrl>")
    }

    if (-not [String]::IsNullOrEmpty($ProjectUrl))
    {
        $null = $nuspecFileContent.AppendLine("    <projectUrl>$ProjectUrl</projectUrl>")
    }

    if (-not [String]::IsNullOrEmpty($IconUrl))
    {
        $null = $nuspecFileContent.AppendLine("    <iconUrl>$IconUrl</iconUrl>")
    }

    $null = $nuspecFileContent.AppendLine("    <requireLicenseAcceptance>true</requireLicenseAcceptance>")
    $null = $nuspecFileContent.AppendLine("    <description>$PackageDescription</description>")
    $null = $nuspecFileContent.AppendLine("    <releaseNotes>$ReleaseNotes</releaseNotes>")
    $null = $nuspecFileContent.AppendLine("    <copyright>Copyright $currentYear</copyright>")
    $null = $nuspecFileContent.AppendLine("    <tags>$Tags</tags>")

    if ($RequiredModules)
    {
        $null = $nuspecFileContent.AppendLine("    <dependencies>")

        ForEach($dependency in $RequiredModules)
        {
            $moduleName = $dependency.ModuleName
            $moduleVersion = "[$($dependency.ModuleVersion)]"
            $null = $nuspecFileContent.AppendLine("      <dependency id='$moduleName' version='$moduleVersion' />")
        }
        $null = $nuspecFileContent.AppendLine("    </dependencies>")
    }

    $null = $nuspecFileContent.AppendLine("  </metadata>")

    if (-not [String]::IsNullOrEmpty($fileList))
    {
        $null = $nuspecFileContent.AppendLine("  <files>")

        foreach ($file in $fileList)
        {
            $null = $nuspecFileContent.AppendLine("    <file src=""$($file.src)"" target=""$($file.target)"" />")
        }
        $null = $nuspecFileContent.AppendLine("  </files>")
    }

    $null = $nuspecFileContent.AppendLine("</package>")

    if (-not $DestinationPath)
    {
        $DestinationPath = $Path
    }

    if (-not (Test-Path -Path $DestinationPath))
    {
        $null = New-Item -Path $DestinationPath -ItemType 'Directory'
    }

    $nuspecFilePath = Join-Path -Path $DestinationPath -ChildPath "$PackageName.nuspec"

    $null = New-Item -Path $nuspecFilePath -ItemType 'File' -Force

    $null = Set-Content -Path $nuspecFilePath -Value $nuspecFileContent.ToString()
}

Export-ModuleMember -Function *
