$supportFileList = Get-ChildItem -Path $PSScriptRoot -Filter '*.Data.ps1'
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
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

    $packageName = (Split-Path -Path $ModuleManifestPath -Leaf) -replace 'psd1', 'nuspec'
    $nuspecFilePath = Join-Path -Path $DestinationPath -ChildPath $packageName
    $nuspecFile = New-Item -Path $nuspecFilePath -ItemType 'File' -Force
    $null = Set-Content -Path $nuspecFilePath -Value $nuspecFileContent
    return $nuspecFile.FullName
}

Export-ModuleMember -Function @(
    'New-NuspecFile'
)
