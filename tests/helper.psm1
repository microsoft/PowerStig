<#
    .SYNOPSIS
        Used to validate an xml file against a specified schema

    .PARAMETER XmlFile
        Path and file name of the XML file to be validated

    .PARAMETER Xml
        An already loaded System.Xml.XmlDocument

    .PARAMETER SchemaFile
        Path of XML schema used to validate the XML document

    .PARAMETER ValidationEventHandler
        Script block that is run when an error occurs while validating XML

    .EXAMPLE
        Test-XML -XmlFile C:\source\test.xml -SchemaFile C:\Source\test.xsd

    .EXAMPLE
        $xmlobject = Get-StigData -OsVersion 2012R2 -OsRole MemberServer
        Test-XML -Xml $xmlobject -SchemaFile C:\Source\test.xsd
#>
function Test-Xml
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true, ParameterSetName = 'File')]
        [string]
        $XmlFile,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true, ParameterSetName = 'Object')]
        [xml]
        $Xml,

        [Parameter(Mandatory = $true)]
        [string]
        $SchemaFile,

        [scriptblock]
        $ValidationEventHandler = { Throw $_.Exception }
    )

    If (-not (Test-Path -Path $SchemaFile))
    {
        Throw "Schema file not found"
    }

    $schemaReader = New-Object System.Xml.XmlTextReader $SchemaFile
    $schema = [System.Xml.Schema.XmlSchema]::Read($schemaReader, $ValidationEventHandler)

    If ($PsCmdlet.ParameterSetName -eq "File")
    {
        $xml = New-Object System.Xml.XmlDocument
        $xml.Load($XmlFile)
    }

    $xml.Schemas.Add($schema) | Out-Null
    $xml.Validate($ValidationEventHandler)
}

function Get-StigDataRootPath
{
    [OutputType([String])]
    [CmdletBinding()]
    param()

    return "$((Get-Module -Name PowerStig -ListAvailable).ModuleBase)\StigData"
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
    [OutputType([PSOject])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CompositeResourceName,

        [Parameter()]
        [string]
        $Filter
    )

    $path = "$((((Get-Module -Name PowerStig -ListAvailable) |
        Sort-Object Version)[-1]).ModuleBase)\StigData\$CompositeResourceName"

    $versions = Get-ChildItem -Path $path -Exclude "*.org.*", "*.xsd"

    $versionTable = @{}
    foreach ($version in $versions)
    {
        if ($version.Basename -match $Filter)
        {
            $versionTable.Add($version.Basename, $version.FullName)
        }
    }

    $versionTable
}

<#
    .SYNOPSIS
        Using an AST, it returns the name of a configuration in the composite resource schema file.

    .PARAMETER FilePath
        The full path to the resource schema module file
#>
function Get-ConfigurationName
{
    [OutputType([String[]])]
    [CmdletBinding()]
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
    [OutputType([String[]])]
    [CmdletBinding()]
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
    [OutputType([String[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CompositeResourceName
    )

    $path = "$(Get-StigDataRootPath)\$CompositeResourceName"

    [string[]] $ValidStigVersionNumbers = Get-ChildItem -Path $path -Exclude "*.org.*" |
        ForEach-Object { ($PSItem.baseName -split "-")[-1] } |
        Select-Object -Unique

    return $ValidStigVersionNumbers
}

Export-ModuleMember -Function @(
    'Get-FileParseErrors',
    'Get-TextFilesList',
    'Test-FileInUnicode',
    'Test-Xml'
    'Get-StigVersionTable',
    'Get-ConfigurationName',
    'Get-StigVersionParameterValidateSet',
    'Get-ValidStigVersionNumbers'
)
