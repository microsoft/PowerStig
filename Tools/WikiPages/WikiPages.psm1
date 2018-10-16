#region Strings

$header = @'
# {0} Class

{1}
'@

$advancedHeader = @'
# {0} Syntax
'@

$constructorHeader = @'

## Constructors

| Name | Description |
|-|-|
'@

$advancedconstructorHeader = @'

## Constructors

'@

$advancedConstructor = @'
{0}

```PowerShell
{1}
```

### Parameters

| Name | Type | Description |
|-|-|-|
{2}

'@

$propertiesHeader = @'

## Properties

| Name | Description |
|-|-|
'@

$advancedPropertyHeader = @'
## {0}

```PowerShell
{1}
```

'@

$methodsHeader = @'

## Methods

| Name | Description |
|-|-|
'@

$advancedMethod = @'
{0}

```PowerShell
{1}
```

### Parameters

{2}

'@

$examplesHeader = @'

## Example
'@

$powershellCodeSnip = @'

'@

#endregion

function Get-WikiContent
{
    [OutputType([hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )

    $input = Get-Content -Path $Path -Raw

    [System.Management.Automation.Language.Token[]] $tokens = $null

    $ast = [System.Management.Automation.Language.Parser]::ParseInput(
        $input, [ref]$tokens, [ref]$null)

    $return = [System.Collections.Specialized.OrderedDictionary]@{}
    <#
        1. Get the Type Definition and Build a hashtable for the
            a. Class
            b. Constructors
            c. Properties
            d. Methods

        2. Modify the Class definition in memory to replace key words with the function key word
        3. Parse the updated script file
        4. Search for FunctionDefinitionAst to get access to GetHelpContent
        5. Update each item in the hashtable from step one with it's help content.
    #>

    $TypeDefinitionAst = $ast.FindAll(
        {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst ]}, $true)

    $return.Add(
        "Class.$($TypeDefinitionAst.Extent.StartLineNumber)",
        @{
            Name = $TypeDefinitionAst.Name
        }
    )

    #Properties
    foreach ($entry in $TypeDefinitionAst.Members.Where( {$PSItem.PropertyType -ne $null}))
    {
        $details = @{
            Name = $entry.Name
            LineNumber = $entry.Extent.StartLineNumber
            PropertyType = $entry.PropertyType.TypeName.FullName
            PropertyAttributes = $entry.PropertyAttributes
            Link = "[Property.$($entry.Name)]: Stig.OrganizationalSettings.Class.Syntax#property$($entry.Name.ToLower())"
        }
        $return.Add("Property.$($entry.Extent.StartLineNumber)", $details)
    }

    # Constructors
    foreach ($entry in $TypeDefinitionAst.Members.Where( {$PSItem.Name -eq $TypeDefinitionAst.Name}))
    {
        $details = @{
            Name = $entry.Name
            LineNumber = $entry.Extent.StartLineNumber
            MethodAttributes = $entry.MethodAttributes
            Parameters = $entry.Parameters
        }

        if ($details.Parameters.Count -gt 0)
        {
            $parameterType = $entry.Parameters.Attributes.TypeName.Name -join "."
            $linkpath = "Constructor.$parameterType"
        }
        else
        {
            $linkpath = "Constructor"
        }

        $details.Add('Link', "[$linkpath]: Stig.$($TypeDefinitionAst.Name).Class.Syntax#$($linkpath.ToLower() -replace "\.",'')")
        $return.Add("Constructor.$($entry.Extent.StartLineNumber)", $details)
    }

    #Methods
    foreach ($entry in $TypeDefinitionAst.Members.Where( {$PSItem.Name -ne $TypeDefinitionAst.Name -and
                $PSItem.MethodAttributes -ne $null}))
    {
        $details = @{
            Name = $entry.Name
            LineNumber = $entry.Extent.StartLineNumber
            PropertyType = $entry.PropertyType.TypeName.FullName
            MethodAttributes = $entry.MethodAttributes
            ReturnType = $entry.ReturnType.TypeName.FullName
            Parameters = $entry.Parameters
        }

        if ($details.Parameters.Count -gt 0)
        {
            $parameterType = $entry.Parameters.Attributes.TypeName.Name
            $linkpath = "Method.$($entry.Name).$parameterType"
        }
        else
        {
            $linkpath = "Method.$($entry.Name)"
        }
        $details.Add('Link', "[$linkpath]: Stig.OrganizationalSettings.Class.Syntax#$($linkpath.ToLower() -replace "\.",'')")
        $return.Add("Method.$($entry.Extent.StartLineNumber)", $details)
    }

    # Update the content with the function keyword to extract help content
    $classAndConstructorFilter = "^(Class)?\s+$($TypeDefinitionAst.Name)(\s+:\s+\w+)?"
    $methodFilter = '^\s*(static)?\s*\[\w*(\[(\s*)?\])?\]\s*'

    $inputModified = (($input -split "`n") -replace $classAndConstructorFilter, "function $($TypeDefinitionAst.Name)")
    <#
        I couldn't come up with a regex that updated the methods without also
        stepping on the class properties, so I just apply the regex against directly
        to the method line number.
    #>
    foreach ($method in $return.Keys.Where( {$PSItem -match "^Method\."}))
    {
        $lineNumber = $return.$method.LineNumber - 1
        $inputModified[$lineNumber] = $inputModified[$lineNumber] -replace $methodFilter, "function "
    }

    $astModified = [System.Management.Automation.Language.Parser]::ParseInput(
        $inputModified, [ref]$tokens, [ref]$null)

    $FunctionDefinitionAst = $astModified.FindAll(
        {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)

    foreach ($Function in $FunctionDefinitionAst)
    {
        $keyName = ($return.Keys.Where( {$PSitem -match ".\.$($Function.Extent.StartLineNumber)"}))[0]

        [void] $return[$keyName].Add('Help', $Function.GetHelpContent())
    }

    return $return
}

<#
    .SYNOPSIS
        The help content is returned as typed, so this function will merge everything
        back into individual sentences and whole lines.
#>
function Format-HelpString
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $String,

        [Parameter()]
        [switch]
        $SingleLine
    )

    $returnString = $String -split "`n" -join " "

    if ($SingleLine)
    {
        $returnString = $returnString -replace "\.\s+", ". "
    }
    else
    {
        $returnString = $returnString -replace "\.\s+", ".`n"
    }

    return $returnString.TrimEnd()
}

function New-WikiPage
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [string]
        $OutputPath
    )

    begin
    {
    }

    process
    {
        $wikiContent = Get-WikiContent -Path $Path

        $helpFileStrings = [System.Collections.ArrayList]@()
        $advancedHelpFileStrings = [System.Collections.ArrayList]@()
        $linkTable = [System.Collections.ArrayList]@('')

        #region Header

        $classKey = ($wikiContent.Keys.Where( {$PSitem -match 'Class\.'}))[0]
        #$classDefinition = $TypeDefinitionAstForHelp.Where({$PSItem.Name -eq $TypeDefinitionAst.Name})
        #$helpString = Get-HelpString -FunctionDefinitionAst $classDefinition -Property DESCRIPTION

        $class = $wikiContent[$classKey]
        $description = Format-HelpString -String $class.Help.Description
        $null = $helpFileStrings.Add(($header -f $class.Name, $description))
        $null = $advancedHelpFileStrings.Add($advancedHeader -f $class.Name)
        #endregion

        #region Constructors
        $constructorKeyList = $wikiContent.Keys.Where( {$PSitem -match 'Constructor\.'})
        $null = $helpFileStrings.Add($constructorHeader)
        $null = $advancedHelpFileStrings.Add($advancedconstructorHeader)

        foreach ($constructorKey in $constructorKeyList.GetEnumerator())
        {
            $constructor = $wikiContent[$constructorKey]

            $link = ($constructor.Link -split "\:")[0]
            $synopsis = Format-HelpString -String $constructor.Help.Synopsis -SingleLine
            $parameterString = $constructor.Parameters.Attributes.TypeName.Name -join ","
            $null = $helpFileStrings.Add("| [$($constructor.name)($parameterString)]$link | $synopsis |")
            $null = $linkTable.Add($constructor.Link)
            # Advanced syntax
            $description = Format-HelpString -String $constructor.Help.Description -SingleLine
            $constructorSyntax = "$($constructor.MethodAttributes) $($constructor.name)($($constructor.Parameters -Join ', '))"

            $parameterList = $constructor.Parameters
            $parameterhelp = $constructor.Help.Parameters

            $parameterHelpString = @()
            foreach ($parameter in $parameterList.GetEnumerator())
            {
                $parameterName = $parameter.Name.VariablePath.UserPath
                $parameterType = $parameter.StaticType.FullName
                $parameterDescription = Format-HelpString -String $parameterhelp.$($parameterName.ToUpper()) -SingleLine

                $parameterHelpString += "| $parameterName | $parameterType | $parameterDescription |"
            }
            $parameterHelpString = $parameterHelpString | Out-String
            $null = $advancedHelpFileStrings.Add(
                ($advancedConstructor -f $description, $constructorSyntax, $parameterHelpString)
            )
        }

        #endregion

        #region Properties
        $propertyKeyList = $wikiContent.Keys.Where( {$PSitem -match 'Property\.'})
        [void]$helpFileStrings.Add($propertiesHeader)

        foreach ($propertyKey in $propertyKeyList.GetEnumerator())
        {
            $property = $wikiContent[$propertyKey]

            $link = ($property.Link -split "\:")[0]
            $helpString = $class.Help.Parameters[$property.Name.ToUpper()]
            $synopsis = Format-HelpString -String $helpString -SingleLine
            $propertyEntry = "| {0} | {1} |" -f "[$($property.Name)]$link", $synopsis
            $null = $helpFileStrings.Add($propertyEntry)
            $null = $linkTable.Add($property.Link)


            $advancedPropertTitle = $link -replace '\[|\]', ''
            $advancedPropertySyntax = "$($property.PropertyAttributes) $($property.PropertyType) {get; set;}"
            $null = $advancedHelpFileStrings.Add(
                ($advancedPropertyHeader -f $advancedPropertTitle,$advancedPropertySyntax)
            )
        }
        #endregion

        #region Methods
        $methodKeyList = $wikiContent.Keys.Where( {$PSitem -match 'Method\.'})
        [void]$helpFileStrings.Add($methodsHeader)

        foreach ($methodKey in $methodKeyList.GetEnumerator())
        {
            $method = $wikiContent[$methodKey]
            $link = ($method.Link -split "\:")[0]
            $synopsis = Format-HelpString -String $method.Help.Synopsis -SingleLine

            $parameterString = $method.Parameters.Attributes.TypeName.Name -join ","
            $methodEntry = "| [$($method.name)($parameterString)]$link | $synopsis |"
            [void] $helpFileStrings.Add($methodEntry)
            [void] $linkTable.Add($method.Link)


            '| Name | Type | Description |'
            '|-|-|-|'
        }
        #endregion
        <#
        #region Examples

        [void]$helpFileStrings.Add($examplesHeader)

        foreach($example in $examples)
        {
            "```PowerShell`n$example`n``` "
        }
        #endregion

        #>


        [void]$helpFileStrings.Add($linkTable)

        $file = Get-Item -Path $path

        $helpFileStrings | Out-File -FilePath $OutputPath\"$($file.BaseName).Class.md"
        $advancedHelpFileStrings | Out-File -FilePath $OutputPath\"$($file.BaseName).Class.Syntax.md"
    }

    end
    {
    }
}

function Get-DscCompositeWikiContent
{
    [OutputType([hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )

    $input = Get-Content -Path $Path -Raw

    [System.Management.Automation.Language.Token[]] $tokens = $null

    $ast = [System.Management.Automation.Language.Parser]::ParseInput(
        $input, [ref]$tokens, [ref]$null)


}

function ConvertTo-Function
{
    [OutputType([System.Management.Automation.Language.FunctionDefinitionAst])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )
    $configurationContent = Get-Content -Path $Path -Raw

    # Update the content with the function keyword to extract help content
    $ConfigurationKeyword = "^Configuration(?=\s+\w+)"
    $inputModified = (($configurationContent -split "`n") -replace $ConfigurationKeyword, "function")


    [System.Management.Automation.Language.Token[]] $tokens = $null
    $astModified = [System.Management.Automation.Language.Parser]::ParseInput(
        $inputModified, [ref]$tokens, [ref]$null)

    $FunctionDefinitionAst = $astModified.FindAll(
        {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)

    return $FunctionDefinitionAst
}

function Get-ConfigurationParameters
{
    [OutputType([hashtable[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $FunctionDefinitionAst
    )

    $help = $FunctionDefinitionAst.GetHelpContent()
    $parameterList = [System.Collections.ArrayList]@()
    foreach ($parameter in $FunctionDefinitionAst.body.ParamBlock.Parameters)
    {
        $parameterName = $parameter.Name.VariablePath.UserPath

        $parametermandatory = $false
        $parameterAttribute = $parameter.Attributes.Where( {$PSItem.TypeName.Name -eq 'Parameter'})
        If ($parameterAttribute.NamedArguments.Where( {$PSItem.ArgumentName -eq 'Mandatory'}).Argument.VariablePath.UserPath -eq $true)
        {
            $parametermandatory = $true
        }

        $parameterObject = @{
            Name = $parameterName
            DataType = $parameter.StaticType.Name
            Attribute = $parametermandatory
        }

        $parameterSetAttribute = $parameter.Attributes.Where( {$PSItem.TypeName.Name -eq 'ValidateSet'})
        if ($null -ne $parameterSetAttribute)
        {
            $null = $parameterObject.Add(
                'AllowedValues', $parameterSetAttribute.PositionalArguments.Value -join ','
            )
        }

        $null = $parameterObject.Add(
            'Description', (Format-HelpString -String $help.Parameters.($parameterName.ToUpper()) -SingleLine )
        )
        $null = $parameterList.Add($parameterObject)
    }
    return $parameterList
}

function Get-ConfigurationExamples
{
    [OutputType([hashtable[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ConfigurationName,

        [Parameter()]
        [string]
        $Path
    )

    $basePath = 'https://github.com/Microsoft/PowerStigDsc/tree/master/Examples'
    $examplelist = [System.Collections.ArrayList]@()

    $filter = "Sample_$ConfigurationName*.ps1"
    $rootPath = ($Path -split 'DscResources')[0]
    $exampleFileList = Get-ChildItem -Path $rootPath -Recurse -Filter $filter

    foreach ($exampleFile in $exampleFileList)
    {
        $configurationContent = ConvertTo-Function -Path $exampleFile.FullName

        $exampleObject = @{
            Text = (Format-HelpString -String $configurationContent.GetHelpContent().Synopsis -SingleLine)
            Link = "$basePath/$($exampleFile.Name)"
        }
        $null = $examplelist.Add($exampleObject)
    }
    return $exampleList
}

<#
    .SYNOPSIS
        Creates a DSC Composite wiki page
#>
function New-DscCompositeWikiPage
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [string]
        $OutputPath
    )

    process
    {
        $wikiStrings = [System.Collections.ArrayList]@()

        $configurationContent = Get-Content -Path $Path -Raw

        [System.Management.Automation.Language.Token[]] $tokens = $null

        $ast = [System.Management.Automation.Language.Parser]::ParseInput(
            $configurationContent, [ref]$tokens, [ref]$null)

        $configuration = $ast.FindAll(
            {$args[0] -is [System.Management.Automation.Language.ConfigurationDefinitionAst]}, $true)

        # ConfigurationName

        $null = $wikiStrings.Add("# $($configuration.InstanceName.Value)")
        $null = $wikiStrings.Add("")

        # Configuration Synopsis as the header text TO DO
        $configurationDetails = ConvertTo-Function -Path $Path
        $help = $configurationDetails.GetHelpContent()
        $null = $wikiStrings.Add("$(Format-HelpString -String $help.Synopsis)")

        $null = $wikiStrings.Add("")
        $null = $wikiStrings.Add("## Requirements")
        $null = $wikiStrings.Add("")

        $requirements = # Get the list of DSC resources and using statements defined in the composite
        if ($requirements)
        {
            # | Resource Name | Resource Version |
        }
        else
        {
            $null = $wikiStrings.Add("None")
        }

        $null = $wikiStrings.Add("")
        $null = $wikiStrings.Add("## Parameters")
        $null = $wikiStrings.Add("")
        $null = $wikiStrings.Add("| Parameter | Attribute | DataType | Description | Allowed Values |")
        $null = $wikiStrings.Add("| --------- | --------- | -------- | ----------- | -------------- |")

        $parameterList = Get-ConfigurationParameters -FunctionDefinitionAst $configurationDetails
        foreach ($parameter in $parameterList)
        {
            $null = $wikiStrings.Add("| $($parameter.Name) | $($parameter.Attribute) | $($parameter.DataType) | $($parameter.Description) | $($parameter.AllowedValues) |")
        }

        $null = $wikiStrings.Add("")
        $null = $wikiStrings.Add("## Examples")
        $null = $wikiStrings.Add("")

        $exampleList = Get-ConfigurationExamples -Configurationname $configuration.InstanceName.Value -Path $Path
        foreach ($example in $exampleList)
        {
            $null = $wikiStrings.Add("* [$($example.Text)]($($example.Link))")
        }

        $wikiStrings | Out-File -FilePath "$OutputPath\$($configuration.InstanceName.Value).md"
    }
}

function New-WikiPageAdvanced
{

}

Export-ModuleMember -Function 'New-WikiPage', 'New-DscCompositeWikiPage'
