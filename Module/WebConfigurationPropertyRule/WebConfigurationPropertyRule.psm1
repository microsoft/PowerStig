# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into a
        WebConfigurationPropertyRule object
    .DESCRIPTION
        The WebConfigurationPropertyRule class is used to extract the web
        configuration settings from the check-content of the xccdf. Once a STIG
        rule is identified as a web configuration property rule, it is passed
        to the WebConfigurationPropertyRule class for parsing and validation.
    .PARAMETER ConfigSection
        The section of the web.config to evaluate
    .PARAMETER Key
        The key in the web.config to evaluate
    .PARAMETER Value
        The value the web.config key should be set to
#>
Class WebConfigurationPropertyRule : Rule
{
    [string] $ConfigSection
    [string] $Key
    [string] $Value

    static [string] $OverrideValue = 'Value'

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf STIG rule element into a WebConfigurationPropertyRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    WebConfigurationPropertyRule ([xml.xmlelement] $StigRule)
    {
        $this.InvokeClass($StigRule)
        $this.SetConfigSection()
        $this.SetKeyValuePair()

        if ($this.IsOrganizationalSetting())
        {
            $this.SetOrganizationValueTestString()
        }

        if ($this.conversionstatus -eq 'pass')
        {
            if ($this.IsDuplicateRule($global:stigSettings))
            {
                $this.SetDuplicateTitle()
            }
        }
        $this.SetDscResource()
    }

    #region Methods

    static [WebConfigurationPropertyRule[]] ConvertFromXccdf ($StigRule)
    {
        $ruleList = @()
        if ([WebConfigurationPropertyRule]::HasMultipleRules($StigRule.rule.Check.'check-content'))
        {
            [string[]] $splitRules = [WebConfigurationPropertyRule]::SplitMultipleRules($StigRule.rule.Check.'check-content')
            foreach ($splitRule in $splitRules)
            {
                $StigRule.rule.Check.'check-content' = $splitRule
                $ruleList += [WebConfigurationPropertyRule]::New($StigRule)
            }
        }
        else
        {
            $ruleList += [WebConfigurationPropertyRule]::New($StigRule)
        }
        return $ruleList
    }

    <#
        .SYNOPSIS
            Extracts the config section from the check-content and sets the value
        .DESCRIPTION
            Gets the config section from the xccdf content and sets the value.
            If the section that is returned is not valid, the parser status is
            set to fail.
    #>
    [void] SetConfigSection ()
    {
        $thisConfigSection = Get-ConfigSection -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisConfigSection))
        {
            $this.set_ConfigSection($thisConfigSection)
        }
    }

    <#
        .SYNOPSIS
            Extracts the key value pair from the check-content and sets the value
        .DESCRIPTION
            Gets the key value pair from the xccdf content and sets the value.
            If the value that is returned is not valid, the parser status is
            set to fail.
    #>
    [void] SetKeyValuePair ()
    {
        $thisKeyValuePair = Get-KeyValuePair -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisKeyValuePair))
        {
            $this.set_Key($thisKeyValuePair.Key)
            $this.set_Value($thisKeyValuePair.Value)
        }
    }

    <#
        .SYNOPSIS
            Tests if and organizational value is required
        .DESCRIPTION
            Tests if and organizational value is required
    #>
    [Boolean] IsOrganizationalSetting ()
    {
        if (-not [String]::IsNullOrEmpty($this.key) -and [String]::IsNullOrEmpty($this.value))
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
            Set the organizational value
        .DESCRIPTION
            Extracts the organizational value from the key and then sets the value
    #>
    [void] SetOrganizationValueTestString ()
    {
        $thisOrganizationValueTestString = Get-OrganizationValueTestString -Key $this.key

        if (-not $this.SetStatus($thisOrganizationValueTestString))
        {
            $this.set_OrganizationValueTestString($thisOrganizationValueTestString)
            $this.set_OrganizationValueRequired($true)
        }
    }

    hidden [void] SetDscResource ()
    {
        $this.DscResource = 'xWebConfigKeyValue'
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match '\.NET Trust Level' -or
            (
                $CheckContent -Match 'IIS 8\.5 web' -and
                $CheckContent -NotMatch 'document'
            ) -and
            (
                $CheckContent -NotMatch 'alternateHostName' -and
                $CheckContent -NotMatch 'Application Pools' -and
                $CheckContent -NotMatch 'bindings' -and
                $CheckContent -NotMatch 'DoD PKI Root CA' -and
                $CheckContent -NotMatch 'IUSR account' -and
                $CheckContent -NotMatch 'Logging' -and
                $CheckContent -NotMatch 'MIME Types' -and
                $CheckContent -NotMatch 'Physical Path' -and
                $CheckContent -NotMatch 'script extensions' -and
                $CheckContent -NotMatch 'recycl' -and
                $CheckContent -NotMatch 'WebDAV' -and
                $CheckContent -NotMatch 'Review the local users' -and
                $CheckContent -NotMatch 'System Administrator' -and
                $CheckContent -NotMatch 'are not restrictive enough to prevent connections from nonsecure zones' -and
                $CheckContent -NotMatch 'verify the certificate path is to a DoD root CA' -and
                $CheckContent -NotMatch 'HKLM' -and
                $CheckContent -NotMatch 'Authorization Rules' -and
                $CheckContent -NotMatch 'regedit <enter>' -and
                $CheckContent -NotMatch 'Enable proxy'
            )
        )
        {
            return $true
        }
        return $false
    }

    <#
        .SYNOPSIS
            Tests if a rule contains multiple checks
        .DESCRIPTION
            Search the rule text to determine if multiple web configurations are defined
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [bool] HasMultipleRules ([string] $CheckContent)
    {
        return Test-MultipleWebConfigurationPropertyRule -CheckContent ([Rule]::SplitCheckContent($CheckContent))
    }

    <#
        .SYNOPSIS
            Splits a rule into multiple checks
        .DESCRIPTION
            Once a rule has been found to have multiple checks, the rule needs
            to be split. This method splits a web configuration into multiple rules.
            Each split rule id is appended with a dot and letter to keep reporting
            per the ID consistent. An example would be is V-1000 contained 2
            checks, then SplitMultipleRules would return 2 objects with rule ids
            V-1000.a and V-1000.b
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [string[]] SplitMultipleRules ([string] $CheckContent)
    {
        return (Split-MultipleWebConfigurationPropertyRule -CheckContent ([Rule]::SplitCheckContent($CheckContent)))
    }

    #endregion
}
