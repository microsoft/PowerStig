using module ..\Rule\Rule.psm1

function Get-StigRuleDetail
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({$_ -match '^V-\d{1,}(|\.[a-z])$'})]
        [string[]]
        $VulnId,

        [Parameter()]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $ProcessedXmlPath = (Join-Path -Path $PSScriptRoot -ChildPath '..\..\StigData\Processed\*.xml')
    )

    $processedXml = Select-String -Path $ProcessedXmlPath -Pattern $VulnId -Exclude '*.org.default.xml' | Sort-Object -Property Pattern

    if ($null -eq $processedXml)
    {
        Write-Warning -Message 'The VulnId(s) specified were not found in the given path'
        return
    }

    $ruleTypeProperty = @{}

    foreach ($technologyXml in $processedXml)
    {
        $ruleIdXPath = '//Rule[@id = "{0}"]' -f $technologyXml.Pattern
        [xml] $xml = Get-Content -Path $technologyXml.Path
        $ruleData = $xml.DISASTIG.SelectNodes($ruleIdXPath)
        $ruleType = $ruleData.ParentNode.ToString()
        if (-not $ruleTypeProperty.ContainsKey($ruleType))
        {
            $uniqueRuleTypeProperty = Get-UniqueRuleTypeProperty -Rule $ruleData
            $ruleTypeProperty.Add($ruleType, $uniqueRuleTypeProperty)
        }

        $ruleDescriptionMatch = [regex]::Match($ruleData.description.Replace("`n", ' '), '<VulnDiscussion>(?<description>.*)<\/VulnDiscussion>')
        $ruleDescriptionValue = $ruleDescriptionMatch.Groups.Item('description').Value
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

        foreach ($value in $ruleTypeProperty[$ruleType])
        {
            $ruleDetail.Add($value, $ruleData.$value)
        }

        [PSCustomObject] $ruleDetail
    }
}

function Get-UniqueRuleTypeProperty
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNodeList]
        $Rule
    )

    $blankRule = New-Object -TypeName Rule
    $commonProperties = ($blankRule | Get-Member -MemberType Property).Name
    $ruleProperty = ($Rule | Get-Member -MemberType Property).Name
    $compareObjResult = Compare-Object -ReferenceObject $ruleProperty -DifferenceObject $commonProperties
    return $compareObjResult.InputObject
}
