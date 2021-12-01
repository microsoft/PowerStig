# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule\Rule.psm1
using module .\..\SqlLoginRule.psm1

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
        Convert the contents of an xccdf check-content element into a SqlLoginRule
    .DESCRIPTION
        The SqlLoginRule class is used to extract the vulnerability ID's that can
        be set with the SqlServerDsc module from the check-content of the xccdf. 
        Once a STIG rule is identified a SqlServerDsc rule, it is passed to the SqlLoginRule 
        class for parsing and validation.
#>

class SqlLoginRuleConvert : SqlLoginRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SqlLoginRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SqlProtocol Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>

    SqlLoginRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetLoginType()
        $this.SetLoginPasswordPolicyEnforced()
        $this.SetLoginPasswordExpirationEnabled()
        $this.SetLoginMustChangePassword()
        $this.SetOrganizationValueTestString()
        $this.SetDscResource()
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the mitigation target name from the check-content and sets
            the value
        .DESCRIPTION
            Gets the mitigation target name from the xccdf content and sets the
            value. If the mitigation target name that is returned is not valid,
            the parser status is set to fail
    #>

    [void] SetLoginType ()
    {
        $thisLoginType = Get-LoginType -CheckContent $this.RawString

        if (-not $this.SetStatus($thisLoginType))
        {
            $this.set_LoginType($thisLoginType)
            $this.Set_OrganizationValueRequired($true)
        }
    }

    [void] SetLoginPasswordPolicyEnforced ()
    {
        $thisLoginPasswordPolicyEnforced = Set-PasswordPolicy -CheckContent $this.rawstring

        if (-not $this.SetStatus($thisLoginPasswordPolicyEnforced))
        {
            $this.set_LoginPasswordPolicyEnforced($thisLoginPasswordPolicyEnforced)
        }
    }

    [void] SetLoginPasswordExpirationEnabled ()
    {
        $thisLoginPasswordExpirationEnabled = Set-PasswordExpiration -CheckContent $this.rawstring

        if (-not $this.SetStatus($thisLoginPasswordExpirationEnabled))
        {
            $this.set_LoginPasswordExpirationEnabled($thisLoginPasswordExpirationEnabled)
        }
    }

    [void] SetLoginMustChangePassword ()
    {
        $thisLoginMustChangePassword = Set-ChangePassword -CheckContent $this.rawstring

        if (-not $this.SetStatus($thisLoginMustChangePassword))
        {
            $this.set_LoginMustChangePassword($thisLoginMustChangePassword)
        }
    }

    [void] SetOrganizationValueTestString ()
    {
        $thisOrganizationValueTestString = Get-SqlLoginOrganizationValueTestString -CheckContent $this.rawstring

        if (-not $this.SetStatus($thisOrganizationValueTestString))
        {
            $this.set_OrganizationValueTestString($thisOrganizationValueTestString)
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match "Check for use of SQL Server Authentication:"
        )
        {
            return $true
        }
        
        return $false
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'SqlLogin'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }
}
