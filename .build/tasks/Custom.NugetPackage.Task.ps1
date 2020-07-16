param(
    # Base directory of all output (default to 'output')
    [Parameter()]
    [string]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output')),

    [Parameter()]
    [string]
    $ChangelogPath = (property ChangelogPath 'CHANGELOG.md'),

    [Parameter()]
    [string]
    $ReleaseNotesPath = (property ReleaseNotesPath (Join-Path $OutputDirectory 'ReleaseNotes.md')),

    [Parameter()]
    [string]
    $ProjectName = (property ProjectName $(
        #Find the module manifest to deduce the Project Name
        (
            Get-ChildItem $BuildRoot\*\*.psd1 -Exclude 'build.psd1', 'analyzersettings.psd1' |
                Where-Object {
                    ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
                    $(
                        try
                        {
                            Test-ModuleManifest $_.FullName -ErrorAction Stop
                        }
                        catch
                        {
                            Write-Warning $_
                            $false
                        }
                    )
                }
        ).BaseName
    )
    ),

    [Parameter()]
    [string]
    $ModuleVersion = (
        property ModuleVersion $(
            try
            {
                (gitversion | ConvertFrom-Json -ErrorAction Stop).NuGetVersionV2
            }
            catch
            {
                Write-Verbose "Error attempting to use GitVersion $($_)"
                ''
            }
        )
    ),

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

Import-Module -Name "$PSScriptRoot/Custom.Functions.psm1"

# Synopsis: Packaging the module by Publishing to output folder (incl dependencies)
task package_module_nupkg {

    # Force registering the output repository mapping to the Project's output path
    $null = Unregister-PSRepository -Name output -ErrorAction SilentlyContinue
    $repositoryParams = @{
        Name            = 'output'
        SourceLocation  = $OutputDirectory
        PublishLocation = $OutputDirectory
        ErrorAction     = 'Stop'
    }

    $null = Register-PSRepository @repositoryParams

    # Cleaning up existing packaged module
    $moduleToRemove = Get-ChildItem -Path (Join-Path -Path $OutputDirectory -ChildPath "$ProjectName.*.nupkg")
    if ($null -ne $moduleToRemove)
    {
        Write-Build DarkGray "  Remove existing $ProjectName package"
        Remove-Item -Path $ModuleToRemove -Force -ErrorAction Stop
    }

    # find Module manifest
    $builtModuleManifest = (Get-ChildItem -Path (Join-Path -Path $OutputDirectory -ChildPath $ProjectName) -Depth 2 -Filter "$ProjectName.psd1").FullName |
        Where-Object {
            try
            {
                Test-ModuleManifest -Path $_ -ErrorAction Stop
            }
            catch
            {
                $false
            }
        }

    if (-not $builtModuleManifest)
    {
        throw "No valid manifest found for project $ProjectName."
    }

    Write-Build -Color DarkGray -Text "  Built module's Manifest found at $builtModuleManifest"

    # load module manifest
    $moduleInfo = Import-PowerShellDataFile -Path $builtModuleManifest

    # Publish dependencies (from environment) so we can publish the built module
    foreach ($module in $moduleInfo.RequiredModules)
    {
        if (
            -not ([Microsoft.PowerShell.Commands.ModuleSpecification]$module |
                Find-Module -Repository output -ErrorAction SilentlyContinue)
        )
        {
            # Replace the module by first (path & version) resolved in PSModulePath
            $module = Get-Module -ListAvailable -FullyQualifiedName $module | Select-Object -First 1
            if ($null -ne $module.PrivateData.PSData.Prerelease)
            {
                $Prerelease = "-" + $module.PrivateData.PSData.Prerelease
            }

            $writeBuildText = "  Packaging Required Module {0} v{1}{2}" -f $Module.Name, $Module.Version.ToString(), $Prerelease
            Write-Build -Color Yellow -Text $writeBuildText
            Publish-Module -Repository output -Path $module.ModuleBase -ErrorAction SilentlyContinue
        }
    }

    Write-Build -Color DarkGray -Text "  Creating nuspec file"
    $projectPath = Join-Path -Path $OutputDirectory -ChildPath $ProjectName
    $manifestFileName = '{0}.psd1' -f $ProjectName
    $moduleManifestPath = Get-ChildItem -Path $projectPath -Filter $manifestFileName -Recurse
    $newNuspecFileParams = @{
        ModuleManifestPath = $moduleManifestPath.FullName
        DestinationPath    = $OutputDirectory
    }
    $projectNuspecFile = New-NuspecFile @newNuspecFileParams
    $nugetResults = Get-Command -Name nuget.exe | Select-Object -First 1
    $nugetFilePath = $nugetResults.Source
    Write-Build -Color DarkGray -Text "  nuget Path: $($nugetFilePath)"
    if ((Test-Path -Path $nugetFilePath) -eq $false)
    {
        throw "nuget.exe not found, aborting task package_module_nupkg"
    }
    else
    {
        $startProcessNugetParams = @{
            FilePath     = $nugetFilePath
            Wait         = $true
            ArgumentList = @(
                'Pack', $projectNuspecFile
                '-OutputDirectory', $OutputDirectory
            )
        }

        Start-Process @startProcessNugetParams
        Write-Build -Color Green -Text "  Packaged $ProjectName NuGet package"
    }

    Write-Build -Color DarkGray -Text "  Cleaning up"
    $null = Unregister-PSRepository -Name output -ErrorAction SilentlyContinue
}
