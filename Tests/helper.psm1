Import-Module $PSScriptRoot\..\PowerStig.psm1

# function Get-PowerStigVersionFromManifest
# {
#     [OutputType([version])]
#     [CmdletBinding()]
#     param
#     (
#         [Parameter(Mandatory)]
#         [string]
#         $ManifestPath
#     )

#     $requiredModules = (Import-PowerShellDataFile -Path $ManifestPath).RequiredModules
#     $powerStigSpecification = ($RequiredModules | Where {$PSItem.ModuleName -eq 'PowerStig'}).ModuleVersion
#     if(-not $powerStigSpecification )
#     {
#         throw "The PowerStig required version was not found in the manifest."
#     }
#     else
#     {
#         return $powerStigSpecification
#     }
# }

function Get-RequiredStigDataVersion
{
    [cmdletbinding()]
    param()

    $Manifest = Import-PowerShellDataFile -Path "$relDirectory\$moduleName.psd1"

    return $Manifest.RequiredModules.Where({$PSItem.ModuleName -eq 'PowerStig'}).ModuleVersion
}

function Get-StigDataRootPath
{
    param ( )

    return Resolve-Path -Path "$PsScriptRoot\..\StigData"
}

<#
    .SYNOPSIS
    Get all of the version files to test

    .PARAMETER CompositeResourceName
    The name of the composite resource used to filter the results
#>
function Get-StigFileList
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CompositeResourceName
    )

    #
    $stigFilePath     = Get-StigDataRootPath
    $stigVersionFiles = Get-ChildItem -Path $stigFilePath -Exclude "*.org*"

    $stigVersionFiles
}

<#
    .SYNOPSIS
    Returns a list of stigs for a given resource. This is used in integration testign by looping
    through every valide STIG found in the StigData directory.

    .PARAMETER CompositeResourceName
    The resource to filter the results

    .PARAMETER Filter
    Parameter description

#>
function Get-StigVersionTable
{
    [outputtype([psobject])]
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CompositeResourceName,

        [Parameter()]
        [string]
        $Filter
    )

    $include = Import-PowerShellDataFile -Path $PSScriptRoot\CompositeResourceFilter.psd1

    $path = "$(Get-StigDataRootPath)\Processed"

    $versions = Get-ChildItem -Path $path -Exclude "*.org.*", "*.xsd" -Include $include.$CompositeResourceName -File -Recurse

    $versionTable = @()
    foreach ($version in $versions)
    {
        if ($version.Basename -match $Filter)
        {
            $stigDetails = $version.BaseName -Split "-"

            $versionTable += @{
                'Technology'        = $stigDetails[0]
                'TechnologyVersion' = $stigDetails[1]
                'TechnologyRole'    = $stigDetails[2]
                'StigVersion'       = $stigDetails[3]
                'Path'              = $version.fullname
           }
        }
    }

    return $versionTable
}

<#
    .SYNOPSIS
    Using an AST, it returns the name of a configuration in the composite resource schema file.

    .PARAMETER FilePath
    The full path to the resource schema module file
#>
function Get-ConfigurationName
{
    [cmdletbinding()]
    [outputtype([string[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $FilePath
    )

    $AST = [System.Management.Automation.Language.Parser]::ParseFile(
        $FilePath, [ref] $null, [ref] $Null
    )

    # Get the Export-ModuleMember details from the module file
    $ModuleMember = $AST.Find( {
            $args[0] -is [System.Management.Automation.Language.ConfigurationDefinitionAst]}, $true)

    return $ModuleMember.InstanceName.Value
}

<#
    .SYNOPSIS
    Returns the list of StigVersion nunmbers that are defined in the ValidateSet parameter attribute

    .PARAMETER FilePath
    THe full path to the resource to read from
#>
function Get-StigVersionParameterValidateSet
{
    [OutputType([string])]
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath
    )

    $compositeResource = Get-Content -Path $FilePath -Raw

    $AbstractSyntaxTree = [System.Management.Automation.Language.Parser]::ParseInput(
        $compositeResource, [ref]$null, [ref]$null)

    $params = $AbstractSyntaxTree.FindAll(
        {$args[0] -is [System.Management.Automation.Language.ParameterAst]}, $true)

    # Filter the specifc ParameterAst
    $paramToUpdate = $params |
        Where-Object {$PSItem.Name.VariablePath.UserPath -eq 'StigVersion'}

    # Get the specifc parameter attribute to update
    $validate = $paramToUpdate.Attributes.Where(
        {$PSItem.TypeName.Name -eq 'ValidateSet'})

    return $validate.PositionalArguments.Value
}

<#
    .SYNOPSIS
    Get a unique list of valid STIG versions from the StigData

    .PARAMETER CompositeResourceName
    The resource to filter the results
#>

function Get-ValidStigVersionNumbers
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $TechnologyRoleFilter
    )

    $versionNumbers = (Get-Stiglist |
        Where-Object {$PSItem.TechnologyRole -match $TechnologyRoleFilter} |
            Select-Object StigVersion -ExpandProperty StigVersion -Unique )

    return $versionNumbers
}

Export-ModuleMember -Function @(
    'Get-PowerStigVersionFromManifest',
    'Get-StigVersionTable',
    'Get-ConfigurationName',
    'Get-StigVersionParameterValidateSet',
    'Get-ValidStigVersionNumbers'
)
