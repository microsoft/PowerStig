param(
    # Base directory of all output (default to 'output')
    [Parameter()]
    [string]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output')),

    [Parameter()]
    $ChangelogPath = (property ChangelogPath 'CHANGELOG.md'),

    [Parameter()]
    $ReleaseNotesPath = (property ReleaseNotesPath (Join-Path $OutputDirectory 'ReleaseNotes.md')),

    [Parameter()]
    [string]
    $ProjectName = (property ProjectName $(
            #Find the module manifest to deduce the Project Name
            (Get-ChildItem $BuildRoot\*\*.psd1 -Exclude 'build.psd1', 'analyzersettings.psd1' | Where-Object {
                    ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
                    $(try
                        {
                            Test-ModuleManifest $_.FullName -ErrorAction Stop
                        }
                        catch
                        {
                            Write-Warning $_
                            $false
                        }) }
            ).BaseName
        )
    ),

    [Parameter()]
    [string]
    $ModuleVersion = (property ModuleVersion $(
            try
            {
                (gitversion | ConvertFrom-Json -ErrorAction Stop).NuGetVersionV2
            }
            catch
            {
                Write-Verbose "Error attempting to use GitVersion $($_)"
                ''
            }
        )),

    [Parameter()]
    [string]
    # retrieves from Environment variable
    $GitHubToken = (property GitHubToken ''),

    [Parameter()]
    [string]
    $GalleryApiToken = (property GalleryApiToken ''),

    [Parameter()]
    [string]
    $NuGetPublishSource = (property NuGetPublishSource 'https://www.powershellgallery.com/'),

    [Parameter()]
    $PSModuleFeed = (property PSModuleFeed 'PSGallery'),

    [Parameter()]
    $SkipPublish = (property SkipPublish '')
)

Import-Module -Name "$PSScriptRoot/Common.Functions.psm1"

# Synopsis: Create ReleaseNotes from changelog and update the Changelog for release
task Create_changelog_release_output {
    "  OutputDirectory  = $OutputDirectory"
    "  ReleaseNotesPath = $ReleaseNotesPath"

    if (!(Split-Path -isAbsolute $OutputDirectory))
    {
        $OutputDirectory = Join-Path $BuildRoot $OutputDirectory
    }

    if (!(Split-Path -isAbsolute $ReleaseNotesPath))
    {
        $ReleaseNotesPath = Join-Path $OutputDirectory $ReleaseNotesPath
    }

    $ChangeLogOutputPath = Join-Path $OutputDirectory 'CHANGELOG.md'
    "  ChangeLogOutputPath = $ChangeLogOutputPath"

    $getModuleVersionParameters = @{
        OutputDirectory = $OutputDirectory
        ProjectName     = $ProjectName
        ModuleVersion   = $ModuleVersion
    }

    $ModuleVersion = Get-ModuleVersion @getModuleVersionParameters

    # Parse the Changelog and extract unreleased
    try
    {
        Import-Module ChangelogManagement -ErrorAction Stop

        # Update the source changelog file
        Update-Changelog -Path $ChangeLogPath -OutputPath $ChangeLogOutputPath -ErrorAction Stop -ReleaseVersion $ModuleVersion -LinkMode none

        # Get the updated CHANGELOG.md
        $changeLogData = Get-ChangelogData -Path $ChangeLogOutputPath

        # Filter out the latest module version change log entries
        $changeLogDataForLatestRelease = $changeLogData.Released | Where-Object -FilterScript {
            $_.Version -eq $ModuleVersion
        }

        <#
            Get the raw markdown release notes for the module manifest. The
            module manifest release notes has a hard size limit when publishing
            to PowerShell Gallery.
        #>
        if ($changeLogDataForLatestRelease.RawData.Length -gt 10000)
        {
            $moduleManifestReleaseNotes = $changeLogDataForLatestRelease.RawData.Substring(0, 10000)
        }
        else
        {
            $moduleManifestReleaseNotes = $changeLogDataForLatestRelease.RawData
        }

        # Create a ReleaseNotes from the Updated changelog
        ConvertFrom-Changelog -Path $ChangeLogOutputPath -Format Release -NoHeader -OutputPath $ReleaseNotesPath -ErrorAction Stop
    }
    catch
    {
        Write-Build Red "Error creating the Changelog Output and/or ReleaseNotes. $($_.Exception.Message)"
    }

    if (-not ($ReleaseNotes = (Get-Content -raw $ReleaseNotesPath -ErrorAction SilentlyContinue)))
    {
        $ReleaseNotes = Get-Content -raw $ChangeLogOutputPath -ErrorAction SilentlyContinue
    }

    if ((Test-Path "$OutputDirectory/$ProjectName/*/$ProjectName.psd1" -ErrorAction SilentlyContinue) -and $ReleaseNotes)
    {
        try
        {
            Import-Module Configuration -ErrorAction Stop
        }
        catch
        {
            Write-Build Red "Issue importing Configuration module. $($_.Exception.Message)"
            return
        }

        # find Module manifest
        $BuiltModuleManifest = (Get-ChildItem (Join-Path $OutputDirectory $ProjectName) -Depth 2 -Filter "$ProjectName.psd1").FullName |
            Where-Object {
                try
                {
                    Test-ModuleManifest -ErrorAction Stop -Path $_
                }
                catch
                {
                    $false
                }
            }
        if (-not $BuiltModuleManifest)
        {
            throw "No valid manifest found for project $ProjectName."
        }
        Write-Build DarkGray "Built Manifest $BuiltModuleManifest"
        # No need to test the manifest again here, because the pipeline tested all manifests via the where-clause already

        # Uncomment release notes (the default in Plaster/New-ModuleManifest)
        $ManifestString = Get-Content -raw $BuiltModuleManifest
        if ( $ManifestString -match '#\sReleaseNotes\s?=')
        {
            $ManifestString = $ManifestString -replace '#\sReleaseNotes\s?=', '  ReleaseNotes ='
            $Utf8NoBomEncoding = [System.Text.UTF8Encoding]::new($False)
            [System.IO.File]::WriteAllLines($BuiltModuleManifest, $ManifestString, $Utf8NoBomEncoding)
        }

        $UpdateReleaseNotesParams = @{
            Path         = "$OutputDirectory/$ProjectName/*/$ProjectName.psd1"
            PropertyName = 'PrivateData.PSData.ReleaseNotes'
            Value        = $moduleManifestReleaseNotes
            ErrorAction  = 'SilentlyContinue'
        }

        Update-Manifest @UpdateReleaseNotesParams
    }
}

task publish_nupkg_to_gallery -if ((Get-Command nuget -ErrorAction SilentlyContinue) -and $GalleryApiToken) {
    $getModuleVersionParameters = @{
        OutputDirectory = $OutputDirectory
        ProjectName     = $ProjectName
        ModuleVersion   = $ModuleVersion
    }

    $ModuleVersion = Get-ModuleVersion @getModuleVersionParameters

    # find Module's nupkg
    $PackageToRelease = Get-ChildItem (Join-Path $OutputDirectory "$ProjectName.$PSModuleVersion.nupkg")
    $ReleaseTag = "v$PSModuleVersion"

    Write-Build DarkGray "About to release $PackageToRelease"
    if (!$SkipPublish)
    {
        $response = &nuget push $PackageToRelease -source $nugetPublishSource -ApiKey $GalleryApiToken
    }
    Write-Build Green "Response = " + $response
}

# Synopsis: Packaging the module by Publishing to output folder (incl dependencies)
task package_module_nupkg {

    # Force registering the output repository mapping to the Project's output path
    $null = Unregister-PSRepository -Name output -ErrorAction SilentlyContinue
    $RepositoryParams = @{
        Name            = 'output'
        SourceLocation  = $OutputDirectory
        PublishLocation = $OutputDirectory
        ErrorAction     = 'Stop'
    }

    $null = Register-PSRepository @RepositoryParams

    # Cleaning up existing packaged module
    if ($ModuleToRemove = Get-ChildItem (Join-Path $OutputDirectory "$ProjectName.*.nupkg"))
    {
        Write-Build DarkGray "  Remove existing $ProjectName package"
        Remove-Item -force -Path $ModuleToRemove -ErrorAction Stop
    }

    # find Module manifest
    $BuiltModuleManifest = (Get-ChildItem (Join-Path $OutputDirectory $ProjectName) -Depth 2 -Filter "$ProjectName.psd1").FullName |
        Where-Object {
            try
            {
                Test-ModuleManifest -ErrorAction Stop -Path $_
            }
            catch
            {
                $false
            }
        }

    if (-not $BuiltModuleManifest)
    {
        throw "No valid manifest found for project $ProjectName."
    }
    Write-Build DarkGray "  Built module's Manifest found at $BuiltModuleManifest"

    # load module manifest
    $ModuleInfo = Import-PowerShellDataFile -Path $BuiltModuleManifest

    # Publish dependencies (from environment) so we can publish the built module
    foreach ($module in $ModuleInfo.RequiredModules)
    {
        if (!([Microsoft.PowerShell.Commands.ModuleSpecification]$module | Find-Module -repository output -ErrorAction SilentlyContinue))
        {
            # Replace the module by first (path & version) resolved in PSModulePath
            $module = Get-Module -ListAvailable -FullyQualifiedName $module | Select-Object -First 1
            if ($Prerelease = $module.PrivateData.PSData.Prerelease)
            {
                $Prerelease = "-" + $Prerelease
            }
            Write-Build Yellow ("  Packaging Required Module {0} v{1}{2}" -f $Module.Name, $Module.Version.ToString(), $Prerelease)
            Publish-Module -Repository output -ErrorAction SilentlyContinue -Path $module.ModuleBase
        }
    }

    Write-Build DarkGray "  Creating nuspec file"
    $projectPath = Join-Path -Path $OutputDirectory -ChildPath $ProjectName
    $manifestFileName = '{0}.psd1' -f $ProjectName
    $moduleManifestPath = Get-ChildItem -Path $projectPath -Filter $manifestFileName -Recurse
    $newNuspecFileParams = @{
        ModuleManifestPath = $moduleManifestPath.FullName
        DestinationPath    = $OutputDirectory
    }
    $projectNuspecFile = New-NuspecFile @newNuspecFileParams
    $nugetFilePath = Join-Path -Path (Get-Module -Name PSDepend -ListAvailable).ModuleBase -ChildPath 'nuget.exe' | Select-Object -Unique
    Write-Warning -Message "nuget Path: $nugetFilePath"
    $startProcessNugetParams = @{
        FilePath     = $nugetFilePath
        Wait         = $true
        ArgumentList = @(
            'Pack', $projectNuspecFile
            '-OutputDirectory', $OutputDirectory
        )
    }

    Start-Process @startProcessNugetParams
    Write-Build Green "  Packaged $ProjectName NuGet package"

    Write-Build DarkGray "  Cleaning up"
    $null = Unregister-PSRepository -Name output -ErrorAction SilentlyContinue
}

task publish_module_to_gallery -if ((!(Get-Command nuget -ErrorAction SilentlyContinue)) -and $GalleryApiToken) {
    if (!(Split-Path $OutputDirectory -IsAbsolute))
    {
        $OutputDirectory = Join-Path $BuildRoot $OutputDirectory
    }

    if (!(Split-Path -isAbsolute $ReleaseNotesPath))
    {
        $ReleaseNotesPath = Join-Path $OutputDirectory $ReleaseNotesPath
    }

    $getModuleVersionParameters = @{
        OutputDirectory = $OutputDirectory
        ProjectName     = $ProjectName
        ModuleVersion   = $ModuleVersion
    }

    $ModuleVersion = Get-ModuleVersion @getModuleVersionParameters

    $ChangeLogOutputPath = Join-Path $OutputDirectory 'CHANGELOG.md'
    "  ChangeLogOutputPath = $ChangeLogOutputPath"

    $changeLogData = Get-ChangelogData -Path $ChangeLogOutputPath

    # Filter out the latest module version change log entries
    $releaseNotesForLatestRelease = $changeLogData.Released | Where-Object -FilterScript {
        $_.Version -eq $ModuleVersion
    }

    # find Module manifest
    $BuiltModuleManifest = (Get-ChildItem (Join-Path $OutputDirectory $ProjectName) -Depth 2 -Filter "$ProjectName.psd1").FullName |
        Where-Object {
            try
            {
                Test-ModuleManifest -ErrorAction Stop -Path $_
            }
            catch
            {
                $false
            }
        }
    # No need to test the manifest again here, because the pipeline tested all manifests via the where-clause already
    if (-not $BuiltModuleManifest)
    {
        throw "No valid manifest found for project $ProjectName."
    }

    # Uncomment release notes (the default in Plaster/New-ModuleManifest)
    $ManifestString = Get-Content -raw $BuiltModuleManifest
    if ( $ManifestString -match '#\sReleaseNotes\s?=')
    {
        $ManifestString = $ManifestString -replace '#\sReleaseNotes\s?=', '  ReleaseNotes ='
        $Utf8NoBomEncoding = [System.Text.UTF8Encoding]::new($False)
        [System.IO.File]::WriteAllLines($BuiltModuleManifest, $ManifestString, $Utf8NoBomEncoding)
    }

    $ModulePath = Join-Path $OutputDirectory $ProjectName

    Write-Build DarkGray "`nAbout to release $ModulePath"

    $PublishModuleParams = @{
        Path         = $ModulePath
        NuGetApiKey  = $GalleryApiToken
        Repository   = $PSModuleFeed
        ErrorAction  = 'Stop'
        ReleaseNotes = $releaseNotesForLatestRelease
    }
    if (!$SkipPublish)
    {
        Publish-Module @PublishModuleParams
    }

    Write-Build Green "Package Published to PSGallery"

}
