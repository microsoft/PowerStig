
<#
    .SYNOPSIS
        Used to process the Check-Content test strings the same way that the SplitCheckContent
        static method does in the the STIG base class.
    .PARAMETER CheckContent
        Strings to process.
#>
function Split-TestStrings
{
    [OutputType([string[]])]
    param
    (
        [Parameter(mandatory = $true)]
        [string]
        $CheckContent
    )

    $CheckContent -split '\n' |
        Select-String -Pattern "\w" |
            ForEach-Object { $PSitem.ToString().Trim() }
}

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
        $ValidationEventHandler = { Throw $PSItem.Exception }
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

<#
    .SYNOPSIS
        Creates a sample xml docuement that injects class specifc data

    .PARAMETER TestFile
        The test rule to merge into the data
#>
function Get-TestStigRule
{
    [CmdletBinding(DefaultParameterSetName = 'UseExisting')]
    param
    (
        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $XccdfTitle = '(Technology) Security Technical Implementation Guide',

        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $XccdfRelease = 'Release: 1 Benchmark Date: 1 Jan 1970',

        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $XccdfVersion = '2',

        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $XccdfId = 'Technology_Target',

        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $CheckContent = 'This is a string of text that tells an admin what item to check to verify compliance.',

        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $GroupId = 'V-1000',

        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $GroupTitle = 'Sample Title',

        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $GroupRuleTitle = 'A more descriptive title.',

        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $GroupRuleDescription = 'A description of what this vulnerability addresses and how it mitigates the threat.',

        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $FixText = 'This is a string of text that tells an admin how to fix an item if it is not currently configured properly and ignored by the parser',

        [Parameter(Parametersetname = 'UseExisting')]
        [string]
        $LegacyId = 'V-1111',

        [Parameter(Parametersetname = 'UseExisting')]
        [Parameter(Parametersetname = 'FileProvided')]
        [switch]
        $ReturnGroupOnly,

        [Parameter(Mandatory = $true, Parametersetname = 'FileProvided')]
        [string]
        $FilePathToGroupElementText
    )

    # If a file path is provided, override the default sample group element text.
    if ( $FilePathToGroupElementText )
    {
        try
        {
            $groupElement = Get-Content -Path $FilePathToGroupElementText -Raw
        }
        catch
        {
            throw "$FilePathToGroupElementText was not found"
        }
    }
    else
    {
        # Get the samplegroup element text and merge in the parameter strings
        $groupElement = Get-Content -Path "$PSScriptRoot\data\sampleGroup.xml.txt" -Encoding UTF8 -Raw
        $groupElement = $groupElement -f $GroupId, $GroupTitle, $RuleTitle, $RuleDescription, $FixText, $CheckContent, $LegacyId
    }

    # Get and merge the group element data into the xccdf xml document and create an xml object to return
    $xmlDocument = Get-Content -Path "$PSScriptRoot\data\sampleXccdf.xml.txt" -Encoding UTF8 -Raw
    [xml] $xmlDocument = $xmlDocument -f $XccdfTitle, $XccdfRelease, $XccdfVersion, $groupElement, $XccdfId

    # Some tests only need the group to test functionality.
    if ($ReturnGroupOnly)
    {
        return $xmlDocument.Benchmark.group
    }

    return $xmlDocument
}

<#
    .SYNOPSIS
        Used to retrieve an array of Stig class base methods and optionally add child class methods
        for purpose of testing methods

    .PARAMETER ChildClassMethodNames
        An array of child class method to add to the class base methods

    .EXAMPLE
        $RegistryRuleClassMethods = Get-StigBaseMethods -ChildClassMethodsNames @('SetKey','SetName')
#>
Function Get-StigBaseMethods
{
    [OutputType([System.Collections.ArrayList])]
    param
    (
        [Parameter()]
        [system.array]
        $ChildClassMethodNames,

        [Parameter()]
        [switch]
        $Static
    )

    if ( $Static )
    {
        $stigClassMethodNames = @('Equals', 'new', 'ReferenceEquals', 'SplitCheckContent',
            'GetFixText')
    }
    else
    {
        $objectClassMethodNames = @('Equals', 'GetHashCode', 'GetType', 'ToString')
        $stigClassMethodNames = @('Clone', 'SetDuplicateRule', 'SetStatus',
            'SetIsNullOrEmpty', 'SetOrganizationValueRequired', 'GetOrganizationValueTestString',
            'ConvertToHashTable', 'IsExistingRule')

        $stigClassMethodNames += $ObjectClassMethodNames
    }

    if ( $ChildClassMethodNames )
    {
        $stigClassMethodNames += $ChildClassMethodNames
    }

    return ( $stigClassMethodNames | Select-Object -Unique )
}

function Format-RuleText
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $RuleText
    )

    $return = ($RuleText -split '\n' |
            Select-String -Pattern "\w" |
            ForEach-Object { $PSitem.ToString().Trim() })

    return $return
}


function Get-RequiredStigDataVersion
{
    [CmdletBinding()]
    param ()

    $Manifest = Import-PowerShellDataFile -Path "$relDirectory\$moduleName.psd1"

    return $Manifest.RequiredModules.Where({$PSItem.ModuleName -eq 'PowerStig'}).ModuleVersion
}

function Get-StigDataRootPath
{
    param ( )

    $projectRoot = Split-Path -Path (Split-Path -Path $PsScriptRoot)
    $buildOutput = Join-Path -Path $projectRoot -ChildPath 'output'
    $manifestPath = (Get-ChildItem -Path $buildOutput -Filter 'PowerStig.psd1' -Recurse).FullName
    $moduleRoot = Split-Path -Path $manifestPath -Parent
    return Join-Path -Path $moduleRoot -Child 'StigData'
}

<#
    .SYNOPSIS
    Get all of the version files to test

    .PARAMETER CompositeResourceName
    The name of the composite resource used to filter the results
#>
function Get-StigFileList
{
    [CmdletBinding()]
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
    [OutputType([psobject])]
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

    $path = "$(Get-StigDataRootPath)\Processed"

    $versions = Get-ChildItem -Path $path -Exclude '*.org.*', '*.xsd', '*.md' -Include "$($CompositeResourceName)-*" -File -Recurse

    $versionTable = @()
    foreach ($version in $versions)
    {
        if ($version.Basename -match $Filter)
        {
            $stigDetails = $version.BaseName -Split "-"

            $currentVersion = @{
                'Technology' = $stigDetails[0]
                'TechnologyVersion' = $stigDetails[1]
                'Path' = $version.fullname
            }

            if ($stigDetails.count -eq 3)
            {
                $currentVersion.Add('TechnologyRole', '')
                $currentVersion.Add('StigVersion', $stigDetails[2])
            }
            elseif ($stigDetails.Count -eq 4)
            {
                $currentVersion.Add('TechnologyRole', $stigDetails[2])
                $currentVersion.Add('StigVersion', $stigDetails[3])
            }

            $versionTable += $currentVersion
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
    [CmdletBinding()]
    [OutputType([string[]])]
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
        Get a unique list of valid STIG versions from the StigData.

    .PARAMETER TechnologyRoleFilter
        The technology role to filter the results.
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

    $versionNumbers = (Get-Stig -ListAvailable |
        Where-Object {$PSItem.TechnologyRole -match $TechnologyRoleFilter} |
            Select-Object StigVersion -ExpandProperty StigVersion -Unique )

    return $versionNumbers
}

<#
    .SYNOPSIS
        Tests whether a STIG has rule types besides Manual and Document Rules

    .PARAMETER StigObject
        A STIG Object to test
#>
function Test-AutomatableRuleType
{
    param
    (
        [Parameter(Mandatory = $true)]
        [xml]
        $StigObject
    )

    $stigRules = $StigObject.DISASTIG

    $propertyNames = (Get-Member -InputObject $stigRules -MemberType 'Property' | Where-Object -FilterScript {$_.Name -match ".*Rule"}).Name

    $automatableRules = $propertyNames | where-object {$_ -ne "ManualRule" -and $_ -ne "DocumentRule"}

    if ($null -ne $automatableRules)
    {
        return $true
    }
    else
    {
        return $false
    }
}

<#
    .SYNOPSIS
        Retrieves the DscResource module name and version.

    .Path
        Specifies the path to the DscResource composite file.
#>
function Get-DscResourceModuleInfo
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Path
    )

    $moduleInfo = @()
    $modulePattern   = "(?<ModuleName>(?<=ModuleName\s)\w*.\w+(?=\s))"
    $versionPatthern = "(?<ModuleVersion>(?<=ModuleVersion\s)[\d\.]+(?=$))"

    $importModuleCommands = Select-String -Path $Path -Pattern 'Import-DscResource' -AllMatches

    foreach ($importModuleCommand in $importModuleCommands)
    {
        $moduleInfo += @{
            ModuleName    = ($importModuleCommand.Line | Select-String -Pattern $modulePattern).Matches[0].Value
            ModuleVersion = ($importModuleCommand.Line | Select-String -Pattern $versionPatthern).Matches[0].Value
        }
    }

    return $moduleInfo
}

<#
    .SYNOPSIS
        Set/Creates ps1 file with 'using module' statement in order to dynamically load
        Rule specific classes.

    .DESCRIPTION
        Sets/Creates a ps1 file with a 'using module' statement with a specified class.
        This function is needed for tests due to the 'using' statement accepting either
        relative paths and/or fully qualified paths. The build process creates an output
        folder with the current version

    .PARAMETER RuleType
        The Rule Type to set in the ps1 file.

    .PARAMETER PowerSTIGBuildPath
        The path where PowerSTIG module was created.

    .PARAMETER DestinationPath
        The path where the ps1 file containing the using statement should reside.
#>
function Set-DynamicClassFile
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $ClassModuleFileName,

        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $PowerStigBuildPath,

        [Parameter(Mandatory = $true)]
        [string]
        $DestinationPath
    )

    $stringBuilder = [System.Text.StringBuilder]::new()
    foreach ($class in $ClassModuleFileName)
    {
        $classModulePath = (Get-ChildItem -Path $PowerStigBuildPath -Filter $class -Recurse).FullName
        $usingStatement = 'using module {0}' -f $classModulePath
        [void] $stringBuilder.AppendLine($usingStatement)
    }

    Set-Content -Value $stringBuilder.ToString() -Path $DestinationPath
}

Export-ModuleMember -Function @(
    'Split-TestStrings'
    'Get-StigDataRootPath'
    'Test-Xml'
    'Get-TestStigRule'
    'Get-StigBaseMethods'
    'Format-RuleText'
    'Get-PowerStigVersionFromManifest'
    'Get-StigVersionTable'
    'Get-ConfigurationName'
    'Get-StigVersionParameterValidateSet'
    'Get-ValidStigVersionNumbers'
    'Test-AutomatableRuleType'
    'Get-DscResourceModuleInfo'
    'Set-DynamicClassFile'
)
