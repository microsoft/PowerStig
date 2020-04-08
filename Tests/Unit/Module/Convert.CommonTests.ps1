#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

<#
    The convert common tests loop through the test data that is provided in the
    form of a hashtable.
    #######################################################
    # The hashtable MUST be in a variable named $testRule #
    #######################################################
    Each key in the hash table is class property name with the exception of
    checkContent. The checkContent contains the sample content from the xccdf
    check-content that would be extracted. All of the other properties are the
    expected results of the extraction.
#>

# Get the rule element with the checkContent injected into it
$stigRule = Get-TestStigRule -CheckContent $testRule.checkContent -ReturnGroupOnly

# Create an instance of the convert class that is currently being tested
$convertedRule = New-Object -TypeName ($global:moduleName + 'Convert') -ArgumentList $stigRule

Describe "$($convertedRule.GetType().Name) Class Instance" {
    # Only run the base class test once
    If ($count -le 0)
    {
        It "Should have a BaseType of $moduleName" {
            $convertedRule.GetType().BaseType.ToString() | Should Be $moduleName
        }
        $count ++
        <#
            Get the List of properties on the Rule base class so that we don't
            test them over and over in the child class tests.
        #>
        $ruleBaseClassPropertyList = [Rule]::new() |
            Get-Member -MemberType Property |
            Select-Object -Property Name -ExpandProperty Name
    }
    # Get the property list to test from the test object
    [System.Collections.ArrayList] $propertyList = $testRule.Keys
    # Remove checkContent from the list since it is not a property
    $propertyList.Remove('CheckContent')

    # Get the properties from the current instance minus the base class properties
    [System.Collections.ArrayList] $ruleClassPropertyTestList = @(
        $convertedRule |
        Get-Member -MemberType Property |
        Select-Object -Property Name -ExpandProperty Name |
        Where-Object {-not $ruleBaseClassPropertyList.Contains($_)}
    )

    # Provide notifications if the test data is missing important properties
    if (-not $testRule.ContainsKey('OrganizationValueRequired'))
    {
        Write-Warning "The OrganizationValueRequired property is not tested. Please add it to the test data hashtable"
    }
    if ($testRule['OrganizationValueRequired'] -and [string]::IsNullOrEmpty($testRule['OrganizationValueTestString']))
    {
        Write-Warning "The OrganizationValueRequired property is set to $true in the test data,
        but the OrganizationValueTestString is empty. Please add it to the test data hashtable."
    }

    # The Document and Manual rules do not have any properies to test
    if ($convertedRule.GetType().Name -notmatch 'DocumentRuleConvert|ManualRuleConvert')
    {
        # Test that each property was properly extracted from the test checkContent
        foreach ($property in $propertyList)
        {
            It "Should return the $Property" {
                # Can't test a null property type, only that the property is null
                if ($null -ne $testRule.$property)
                {
                    # Some properties are complex types that need to be serialized for comparison
                    if ($testRule.$property.GetType().BaseType.Name -eq 'Array')
                    {
                        $convertedRule.$property = $convertedRule.$property | ConvertTo-Json
                        $testRule.$property = $testRule.$property | ConvertTo-Json
                    }
                }
                $convertedRule.$property | Should Be $testRule.$property
            }
            # Remove the property from the list of tested properties
            $ruleClassPropertyTestList.Remove($property)
        }
    }
    <#
        After looping through the properties, provide a notification if any
        properties were not tested.
    #>
    foreach ($ruleClassProperty in $ruleClassPropertyTestList)
    {
        Write-Warning "$ruleClassProperty is not currently tested"
    }
    <#
        When the xccdf xml is loaded by System.Xml.XmlDocument in the module,
        the xml parser decodes html elements. The Match method is expecting
        decoded strings. To keep the test data consistent with the xccdf xml it
        needs to be decoded before testing.
    #>
    Add-Type -AssemblyName System.Web
    $checkContent = [System.Web.HttpUtility]::HtmlDecode( $testRule.checkContent )

    # The manual rule is the default and does not contain a match method.
    if ($convertedRule.GetType().Name -notmatch 'ManualRuleConvert')
    {
        <#
            To dynamically call a static method, we have to get the static method
            from the current runtime and then invoke it with its expected parameters.
        #>
        $match = $convertedRule.GetType().GetMethod('Match')
        # Test the required convert module static method
        Describe 'Static Match' {
            It 'Should Match the string' {
                $match.Invoke($convertedRule, $checkContent) | Should Be $true
            }
        }
    }
}
