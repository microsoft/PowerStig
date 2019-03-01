# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\SslSettingsRule.psm1

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
#>
Class SslSettingsRuleConvert : SslSettingsRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SslSettingsRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf STIG rule element into a Web Configuration Property Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    SslSettingsRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {
        $this.SetSslValue()

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
    <#
        .SYNOPSIS
            Extracts the key value pair from the check-content and sets the value
        .DESCRIPTION
            Gets the key value pair from the xccdf content and sets the value.
            If the value that is returned is not valid, the parser status is
            set to fail.
    #>
    [void] SetSslValue ()
    {
        switch ( $this.splitcheckContent )
        {
            { $PSItem -match 'Verify the "Clients Certificate Required"' }
            {
                $value = 'SslRequireCert'
            }
            { $PSItem -match 'If the "Require SSL"' }
            {
                $value = 'Ssl'
            }
            { ($PSItem -match 'Client Certificates Required') -and ($PSItem -match 'set to "ssl128"') -and ($PSItem -match 'If the "Require SSL"') }
            {
                $value = 'Ssl,SslNegotiateCert,SslRequireCert,Ssl128'
            }
        }
    
        if ($null -ne $value)
        {
            Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found value: {0}"  -f $value)
    
            $thisSslValue = @{
                value = $value
            }

            if (-not $this.SetStatus($thisSslValue))
            {
                $this.set_Value($thisSslValue.Value)
            }
        }
        else
        {   
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] No Key or Value found"
        }
    }

    hidden [void] SetDscResource ()
    {
        $this.DscResource = 'xSslSettings'
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match 'SSL Settings' 
        )
        {
            return $true
        }
        return $false
    }

    #endregion
}
