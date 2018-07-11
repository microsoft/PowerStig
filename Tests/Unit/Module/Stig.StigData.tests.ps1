#region Header
using module .\..\..\..\Module\Common\Common.psm1
using module .\..\..\..\Module\Stig.StigException\Stig.StigException.psm1
using module .\..\..\..\Module\Stig.StigProperty\Stig.StigProperty.psm1
using module .\..\..\..\Module\Stig.SkippedRuleType\Stig.SkippedRuleType.psm1
using module .\..\..\..\Module\Stig.SkippedRule\Stig.SkippedRule.psm1
using module .\..\..\..\Module\Stig.OrganizationalSetting\Stig.OrganizationalSetting.psm1
using module .\..\..\..\Module\Stig.TechnologyRole\Stig.TechnologyRole.psm1
using module .\..\..\..\Module\Stig.TechnologyVersion\Stig.TechnologyVersion.psm1
using module .\..\..\..\Module\Stig.StigData\Stig.StigData.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $schemaFile = Join-Path -Path (Resolve-Path $PSScriptRoot\..\..\..\).Path `
                                -ChildPath "\StigData\Schema\PowerStig.xsd"

        [hashtable] $orgSettingHashtable = @{
            "V-1114"   = "xGuest";
            "V-1115"   = "xAdministrator";
            "V-3472.a" = "NT5DS";
            "V-4108"   = "90";
            "V-4113"   = "300000";
            "V-8322.b" = "NT5DS";
            "V-26482"  = "Administrators";
            "V-26579"  = "32768";
            "V-26580"  = "196608";
            "V-26581"  = "32768"
        }

        $orgSettings = [OrganizationalSetting]::ConvertFrom($orgSettingHashtable)

        $technologyVersionName = '2012R2';
        $technologyRoleName = 'DC';

        $technology = [Technology]::Windows
        $technologyVersion = [TechnologyVersion]::new($technologyVersionName, $technology)
        $technologyRole = [TechnologyRole]::new($technologyRoleName, $technologyVersion)

        $stigVersion = [StigData]::GetHighestStigVersion($technology, $technologyRole, $technologyVersion)

        [hashtable] $stigExceptionHashtable = @{
            "V-26606" = @{'ServiceState' = 'Running';
                          'StartupType'  = 'Automatic'};
            "V-15683" = @{'ValueData' = '1'};
            "V-26477" = @{'Identity' = 'Administrators'};
        }

        $stigExceptions = [StigException]::ConvertFrom($stigExceptionHashtable)

        [string[]] $skippedRuleTypeArray = @(
            "AccountPolicyRule"
        )

        $skippedRuleTypes = [SkippedRuleType]::ConvertFrom($skippedRuleTypeArray)

        [string[]] $skippedRuleArray = @(
            "V-1114",
            "V-1115",
            "V-3472.a",
            "V-4108",
            "V-4113",
            "V-8322.b",
            "V-26482",
            "V-26579",
            "V-26580",
            "V-26581"
        )

        $skippedRules = [SkippedRule]::ConvertFrom($skippedRuleArray)
        #endregion StigData1 Test Data
        #region Class Tests
        Describe "StigData Class" {

            Context "Constructor" {

                It "Should create an StigData class instance using StigData1 data" {
                    {$script:stigData = [StigData]::new($stigVersion, $orgSettings,
                            $technology, $technologyRole, $technologyVersion,
                            $stigExceptions, $skippedRuleTypes, $skippedRules)} |
                        Should Not Throw
                }
                It "Should return the Stig Version" {
                    $script:stigData.StigVersion | Should Be $stigVersion
                }

                # $organizationalSettings = $stigData.OrganizationalSettings
                # foreach ($hash in $orgSettingHashtable.GetEnumerator())
                # {
                #     $orgSetting = $organizationalSettings.Where( {$_.StigRuleId -eq $hash.Key})
                #     $orgSetting.StigRuleId | Should Be $hash.Key
                #     $orgSetting.Value | Should Be $hash.Value
                # }

                It "Should return the Stig Technology" {
                    $script:stigData.Technology.Name | Should Be $technology.Name
                }
                It "Should return the Stig Technology Version" {
                    $script:stigData.TechnologyVersion.Name | Should Be $technologyVersion.Name
                }
                It "Should return the Stig Technology Role" {
                    $stigData.TechnologyRole.Name | Should Be $technologyRole.Name
                }
                # $stigExceptions = $stigData.StigExceptions
                # foreach ($hash in $stigExceptionHashtable.GetEnumerator())
                # {
                #     $stigException = $stigExceptions.Where({$_.StigRuleId -eq $hash.Key})
                #     $stigException.StigRuleId | Should Be $hash.Key

                #     foreach ($property in $hash.Value.GetEnumerator())
                #     {
                #         $stigProperty = $stigException.Properties.Where({$_.Name -eq $property.Key})
                #         $stigProperty.Name | Should Be $property.Key
                #         $stigProperty.Value | Should Be $property.Value
                #     }
                # }
                It "Should not have commented out tests" {
                    $false | Should Be $true
                }
                # $skippedRuleTypes = $stigData.SkippedRuleTypes
                # foreach ($type in $skippedRuleTypeArray)
                # {
                #     $skippedRuleType = $skippedRuleTypes.Where( {$_.StigRuleType.ToString() -eq $type})
                #     $skippedRuleType.StigRuleType | Should Be $type
                # }

                # $skippedRules = $stigData.SkippedRules
                # foreach ($rule in $skippedRuleArray)
                # {
                #     $skippedRule = $skippedRules.Where( {$_.StigRuleId -eq $rule})
                #     $skippedRule.StigRuleId | Should Be $rule
                # }
                It "Should create an StigData class with the highest available version because no StigVersion was provided" {
                    $stigData = [StigData]::new($null, $orgSettings, $technology, $technologyRole, $technologyVersion, $stigExceptions, $skippedRuleTypes, $skippedRules)
                    $stigData.StigVersion | Should Not Be $null
                }

                It "Should throw an exception when Technology is Null" {
                    { [StigData]::new($stigVersion, $orgSettings, $null, $technologyRole, $technologyVersion, $stigExceptions, $skippedRuleTypes, $skippedRules) } `
                        | Should Throw
                }

                It "Should throw an exception when TechnologyVersion is Null" {
                    { [StigData]::new($stigVersion, $orgSettings, $technology, $technologyRole, $null, $stigExceptions, $skippedRuleTypes, $skippedRules) } `
                        | Should Throw
                }

                It "Should throw an exception when TechnologyRole is Null" {
                    { [StigData]::new($stigVersion, $orgSettings, $technology, $null, $technologyVersion, $stigExceptions, $skippedRuleTypes, $skippedRules) } `
                        | Should Throw
                }
            }

            Context "Instance Methods" {
                It "SetStigPath: Should be able to determine the StigPath for the provided valid set of Technology, TechnologyVersion, TechnologyRole, and StigVersion" {
                    $stigData = [StigData]::new($stigVersion, $orgSettings, $technology, $technologyRole, $technologyVersion, $stigExceptions, $skippedRuleTypes, $skippedRules)
                    $stigData.SetStigPath()
                    $stigData.StigPath | Should Be "$([StigData]::GetRootPath())\$($technology.ToString())-$($technologyVersion.Name)-$($technologyRole.Name)-$($stigVersion).xml"
                }

                It "ProcessStigData: Should load the Stig Xml document from the filesystem into the StigXml property" {
                    $stigData = [StigData]::new($stigVersion, $orgSettings, $technology, $technologyRole, $technologyVersion, $stigExceptions, $skippedRuleTypes, $skippedRules)
                    $stigData.StigXml | Should Not Be $null
                }

                It "SetStigPath: Should throw an exception if it is unable to find a matching Stig for the provided Technology, TechnologyVersion, TechnologyRole, and StigVersion" {
                    { [StigData]::new('111.222', $orgSettings, $technology, $technologyRole, $technologyVersion,
                            $stigExceptions, $skippedRuleTypes, $skippedRules) } | Should Throw
                }

                It "MergeOrganizationalSettings: Should merge the default organizational settings into instance OrganizationalSettings when no OrganizationalSettings is provided for a Stig that requires them" {
                    $stigData = [StigData]::new($stigVersion, $null, $technology, $technologyRole, $technologyVersion, $stigExceptions, $skippedRuleTypes, $skippedRules)
                    $stigData.OrganizationalSettings | Should Not Be $null
                    $stigData.OrganizationalSettings.Length | Should BeGreaterThan 0
                }

                It "MergeOrganizationalSettings: Should merge provided settings into instance OrganizationalSettings for a Stig that requires them" {
                    $stigData = [StigData]::new($stigVersion, $orgSettings, $technology, $technologyRole, $technologyVersion, $stigExceptions, $skippedRuleTypes, $skippedRules)

                    $organizationalSettings = $stigData.OrganizationalSettings
                    foreach ($hash in $orgSettingHashtable.GetEnumerator())
                    {
                        $orgSetting = $organizationalSettings.Where( {$_.StigRuleId -eq $hash.Key})
                        $orgSetting.StigRuleId | Should Be $hash.Key
                        $orgSetting.Value | Should Be $hash.Value
                    }
                }

                It "MergeOrganizationalSettings: Should merge instance OrganizationalSettings into StigXml" {
                    $stigData = [StigData]::new($stigVersion, $orgSettings, $technology, $technologyRole, $technologyVersion, $stigExceptions, $skippedRuleTypes, $skippedRules)

                    $propertyMap = [OrganizationalSetting]::PropertyMap()

                    foreach ($rule in $stigData.OrganizationalSettings)
                    {
                        $ruleToCheck = ( $stigData.StigXml.DISASTIG | Select-Xml -XPath "//Rule[@id='$( $rule.StigRuleId )']" -ErrorAction Stop ).Node

                        if ($null -ne $ruleToCheck)
                        {
                            $ParentNodeName = $ruleToCheck.ParentNode.Name
                            if ($ParentNodeName -ne "SkipRule")
                            {
                                $OverridePropertyName = $propertyMap.$ParentNodeName
                                $ruleToCheck.$OverridePropertyName | Should Be $rule.Value
                            }
                        }
                    }
                }

                It "MergeOrganizationalSettings: Should pass schema testing after organizational settings have been merged" {
                    $stigData = [StigData]::new($stigVersion, $orgSettings, $technology, $technologyRole, $technologyVersion, $null, $null, $null)

                    { Test-Xml -Xml $stigData.StigXml -SchemaFile $schemaFile } | Should Not Throw
                }

                It "MergeStigExceptions: Should merge the supplied stig exceptions when StigExceptions is not Null" {
                    $stigData = [StigData]::new($stigVersion, $null, $technology, $technologyRole, $technologyVersion, $stigExceptions, $null, $null)

                    foreach ($exception in $stigData.StigExceptions)
                    {
                        $ruleToCheck = ( $stigData.StigXml.DISASTIG | Select-Xml -XPath "//Rule[@id='$( $exception.StigRuleId )']" -ErrorAction Stop ).Node

                        if ($null -ne $ruleToCheck)
                        {
                            $ParentNodeName = $ruleToCheck.ParentNode.Name
                            if ($ParentNodeName -ne "SkipRule")
                            {
                                foreach ($property in $exception.Properties)
                                {
                                    $ruleToCheck.$($property.Name) | Should Be $property.Value
                                }
                            }
                        }
                    }
                }

                It "MergeStigExceptions: Should pass schema testing after stig exceptions have been merged" {
                    $stigData = [StigData]::new($stigVersion, $null, $technology, $technologyRole, $technologyVersion, $stigExceptions, $null, $null)

                    { Test-Xml -Xml $stigData.StigXml -SchemaFile $schemaFile } | Should Not Throw
                }

                It "ProcessSkippedRuleTypes: Should process the supplied skipped rule types when SkippedRuleTypes is not Null" {
                    $stigData = [StigData]::new($stigVersion, $null, $technology, $technologyRole, $technologyVersion, $null, $skippedRuleTypes, $null)

                    $stigData.SkippedRules | Should Not Be $null
                    $stigData.SkippedRules.Length | Should BeGreaterThan 0
                }

                It "MergeSkippedRules: Should merge the supplied skipped rules when SkippedRules is not Null" {
                    $stigData = [StigData]::new($stigVersion, $null, $technology, $technologyRole, $technologyVersion, $null, $skippedRuleTypes, $skippedRules)

                    foreach ($skippedRule in $stigData.SkippedRules)
                    {
                        $ruleToCheck = ( $stigData.StigXml.DISASTIG.SkipRule | Select-Xml -XPath "//Rule[@id='$( $skippedRule.StigRuleId )']" -ErrorAction Stop ).Node

                        $ruleToCheck | Should Not Be $null
                    }
                }

                It "MergeSkippedRules: Should pass schema testing after skipped rules have been merged" {
                    $stigData = [StigData]::new($stigVersion, $null, $technology, $technologyRole, $technologyVersion, $null, $skippedRuleTypes, $skippedRules)

                    { Test-Xml -Xml $stigData.StigXml -SchemaFile $schemaFile } | Should Not Throw
                }

                It "Should pass schema testing after with values passed in to all parameters" {
                    $stigData = [StigData]::new($stigVersion, $orgSettings, $technology, $technologyRole, $technologyVersion, $stigExceptions, $skippedRuleTypes, $skippedRules)

                    { Test-Xml -Xml $stigData.StigXml -SchemaFile $schemaFile } | Should Not Throw
                }
            }
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
