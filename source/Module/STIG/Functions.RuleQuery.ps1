using module ..\Rule\Rule.psm1

<#
    .SYNOPSIS
        Get the STIG Rule Details for a given rule supported by PowerSTIG.

    .DESCRIPTION
        Get the STIG Rule Details for a given rule supported by PowerSTIG.

    .PARAMETER VulnId
        VulnId within PowerSTIG is typically labled as the RuleId, which
        may not be consistent with DISA terminology.

    .PARAMETER ProcessedXmlPath
        Either the folder where the processed xml resides or a specific xml path.
        The default is .\StigData\Processed\*.xml

    .EXAMPLE
        PS> Get-StigRule -VulnId 'V-1114', 'V-1115'

        This example will return the rule details for V-1114 and V-1115 from the Windows Server
        2012 R2 Member Server and Domain Controller STIGs.
#>
function Get-StigRule
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({$_ -match '^V-\d{1,}(|\.[a-z])$'})]
        [Alias("RuleId")]
        [string[]]
        $VulnId,

        [Parameter()]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $ProcessedXmlPath = (Join-Path -Path $PSScriptRoot -ChildPath '..\..\StigData\Processed\*.xml'),

        [Parameter()]
        [switch]
        $Detailed
    )

    $processedXml = Select-String -Path $ProcessedXmlPath -Pattern $VulnId -Exclude '*.org.default.xml' | Sort-Object -Property Pattern

    if ($null -eq $processedXml)
    {
        Write-Warning -Message "The VulnId(s) specified were not found in $ProcessedXmlPath"
        return
    }

    # hashtable to store rule property lookups when multiple rule types are specified
    $ruleTypeProperty = @{}

    foreach ($technologyXml in $processedXml)
    {
        # based on the VulnId specificed use XPath to search the xml object
        $ruleIdXPath = '//Rule[@id = "{0}"]' -f $technologyXml.Pattern
        [xml] $xml = Get-Content -Path $technologyXml.Path
        $ruleData = $xml.DISASTIG.SelectNodes($ruleIdXPath)
        $ruleType = $ruleData.ParentNode.ToString()

        # if the current rule type is not stored in the hashtable, run Get-UniqueRuleTypeProperty and store the results for future use
        if (-not $ruleTypeProperty.ContainsKey($ruleType))
        {
            $uniqueRuleTypeProperty = Get-UniqueRuleTypeProperty -Rule $ruleData
            $ruleTypeProperty.Add($ruleType, $uniqueRuleTypeProperty)
        }

        # pulling the VulnDiscussion as the description out of the xml using a regex capture group
        $ruleDescriptionMatch = [regex]::Match($ruleData.description.Replace("`n", ' '), '<VulnDiscussion>(?<description>.*)<\/VulnDiscussion>')

        # address edge case where an out of place OS Control charactor [char]157 in the STIG's description, i.e. Adobe Reader / V-64919, removing it
        $ruleDescriptionValue = $ruleDescriptionMatch.Groups.Item('description').Value -replace '\u009D'

        # using PSv3 "ordered" to create an ordered hashtable for PSCustomObject property list display order
        if ($PSBoundParameters.ContainsKey('Detailed'))
        {
            $ruleDetail = [ordered] @{
                StigId                      = $xml.DISASTIG.stigid
                StigVersion                 = $xml.DISASTIG.fullversion
                VulnId                      = $ruleData.id
                Severity                    = $ruleData.severity
                Title                       = $ruleData.title
                Description                 = $ruleDescriptionValue
                RuleType                    = $ruleType
                DscResource                 = $ruleData.dscresource
                DuplicateOf                 = $ruleData.DuplicateOf
                OrganizationValueRequired   = $ruleData.OrganizationValueRequired
                OrganizationValueTestString = $ruleData.OrganizationValueTestString
            }
        }
        else
        {
            $ruleDetail = [ordered] @{
                RuleType = $ruleType
            }
        }

        # adding the rule specific properties to the ordered hashtable and then casting to PSCustomObject
        foreach ($value in $ruleTypeProperty[$ruleType])
        {
            $ruleDetail.Add($value, $ruleData.$value)
        }

        [PSCustomObject] $ruleDetail
    }
}

<#
    .SYNOPSIS
        Get the unique rule type properties given a specific rule type.

    .DESCRIPTION
        Get the unique rule type properties given a specific rule type.

    .PARAMETER Rule
        A rule by leveraging the selected XmlNodeList from a processed xml.

    .EXAMPLE
        PS> Get-UniqueRuleTypeProperty -Rule $xml.DISASTIG.RegistryRule.Rule[0]

        Returns the delta properties between the RegistryRule and Base Rule class

#>
function Get-UniqueRuleTypeProperty
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Object]
        $Rule
    )

    $blankRule = New-Object -TypeName Rule
    $commonProperties = ($blankRule | Get-Member -MemberType Property).Name
    $ruleProperty = ($Rule | Get-Member -MemberType 'NoteProperty', 'Property').Name
    $compareObjResult = Compare-Object -ReferenceObject $ruleProperty -DifferenceObject $commonProperties
    return $compareObjResult.InputObject
}

function Get-StigRuleExceptionString
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSObject[]]
        $Rule,

        [Parameter()]
        [switch]
        $Formatted
    )

    begin
    {
        $ruleTypeProperty = @{}
    }

    process
    {
        foreach ($ruleData in $Rule)
        {
            if (-not $ruleTypeProperty.ContainsKey($ruleData.RuleType))
            {
                $uniqueRuleTypeProperty = Get-UniqueRuleTypeProperty -Rule $ruleData
                $ruleTypeProperty.Add($ruleData.RuleType, $uniqueRuleTypeProperty)
            }

            $ruleDetail = [ordered] @{
                RuleType = $ruleData.RuleType
            }

            foreach ($value in $ruleTypeProperty[$ruleData.RuleType])
            {
                $ruleDetail.Add($value, $ruleData.$value)
            }


        }
    }
}
