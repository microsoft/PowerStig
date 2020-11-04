# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule\Rule.psm1
using module .\..\RootCertificateRule.psm1

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
        Convert the contents of an xccdf check-content element into a Root Certificate object
    .DESCRIPTION
        The RootCertificateRule class is used to extract the DoD Root Certificate details
        from the check-content of the xccdf. Once a STIG rule is identified a
        Root Certificate rule, it is passed to the RootCertificateRule class for parsing
        and validation.
#>
class RootCertificateRuleConvert : RootCertificateRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    RootCertificateRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts an xccdf stig rule element into a Root Certificate Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    RootCertificateRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetRootCertificateName()
        $this.SetRootCertificateThumbprint()
        $this.SetOrganizationValueTestString()
        $this.SetDscResource()
    }

    # Methods
    <#
    .SYNOPSIS
        Extracts the Root Certificate Name from the check-content and sets the Certificate Name
    .DESCRIPTION
        Gets the Root Certificate Name from the xccdf content.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
    [void] SetRootCertificateName ()
    {
        $certificateName = Set-RootCertificateName -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($certificateName))
        {
            $this.set_CertificateName($certificateName)
        }
    }

    <#
    .SYNOPSIS
        Extracts the Root Certificate Thumbprint from the check-content and sets the Certificate Thumbprint
    .DESCRIPTION
        Gets the Root Certificate Thumbprint from the xccdf content.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
    [void] SetRootCertificateThumbprint()
    {
        $thumbprint = Set-RootCertificateThumbprint -CheckContent $this.SplitCheckContent
        if (-not $this.SetStatus($thumbprint))
        {
            $this.set_Thumbprint($thumbprint)
        }
    }

    <#
    .SYNOPSIS
        Sets organizational value to required because all certificates require a location parameter defined by config
    .DESCRIPTION
        The organizational settings is always required for root certificate rules
    #>
    [bool] IsOrganizationalSetting ()
    {
        return $true
    }

    <#
    .SYNOPSIS
        Set the organizational value
    .DESCRIPTION
        Extracts the organizational value from the Certificate Name and then sets the value
    #>
    [void] SetOrganizationValueTestString ()
    {
        $OrganizationValueTestString = Get-OrganizationValueTestString -CertificateName $this.CertificateName

        if (-not $this.SetStatus($OrganizationValueTestString))
        {
            $this.set_OrganizationValueTestString($OrganizationValueTestString)
            $this.set_OrganizationValueRequired($true)
        }
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'CertificateDSC'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if ($CheckContent -match 'CN=DoD')
        {
            return $true
        }

        return $false
    }

    <#
        .SYNOPSIS
            Tests if a rule contains multiple checks
        .DESCRIPTION
            Search the rule text to determine if multiple {0} are defined
        .PARAMETER Name
            The feature name from the rule text from the check-content element
            in the xccdf
    #>

    static [bool] HasMultipleRules ([string] $CheckContent)
    {
        return (Test-MultipleRootCertificateRule -CheckContent ([RootCertificateRule]::SplitCheckContent($CheckContent)))
    }

    <#
        .SYNOPSIS
            Splits a rule into multiple checks
        .DESCRIPTION
            Once a rule has been found to have multiple checks, the rule needs
            to be split. This method splits a windows feature into multiple rules.
            Each split rule id is appended with a dot and letter to keep reporting
            per the ID consistent. An example would be is V-1000 contained 2
            checks, then SplitMultipleRules would return 2 objects with rule ids
            V-1000.a and V-1000.b
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [string[]] SplitMultipleRules ([string] $CheckContent)
    {
        return (Split-MultipleRootCertificateRule -CheckContent ([RootCertificateRule]::SplitCheckContent($CheckContent)))
    }

}
