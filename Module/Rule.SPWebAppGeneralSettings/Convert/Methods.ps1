# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

function Get-SPWebAppGeneralSettingsGetScript
{
    [CmdletBinding()]
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        $CheckContent,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        $OrgSettings,

        [Parameter(Mandatory = $false)]
        [SecureString] $PSDscRunAsCredential
    )

    <#
    write function call here to webappurl?
    results are returned as a hashtable
    $returnvalue = @{
        WebAppUrl = $WebAppUrl
        PSDscRunAsCredential = $PSDscRunAsCredential
    }
    #>

    <#
        Get/Test/Set processing for rule type
    #>

    

    #Write-Host $OrgSettings #worry about orgsettings capture later

    return
}

#write a function here to receive webappurl parameter? (line 25)

function Get-SPWebAppGeneralSettingsTestScript
{
    [CmdletBinding()]
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        $CheckContent
    )

    #testing dsc configuration

        return
    
}

function Get-SPWebAppGeneralSettingsSetScript
{
    [CmdletBinding()]
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [string[]]
        $FixText,    

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        $CheckContent
    )

    #applying settings for compliance

        return
}

function Get-SPWebAppGeneralSettingsRuleSubType
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    $content = $CheckContent -join " "

    switch ($content)
    {
        
        {
            $PSItem -Match "prohibited mobile code" -or #V-59957
            $PSItem -Match "SharePoint server configuration to ensure a session lock" -or #V-59919
            $PSItem -Match "ensure user sessions are terminated upon user logoff" -or #V-59977
            $PSItem -Match "ensure access to the online web part gallery is configured" #V-59991
        }
        {
            $ruleType = "SPWebAppGeneralSettings"
        }

        default
        {
            $ruleType = 'Manual'
        }
    }

    return $ruleType
}

function Test-VariableRequired
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Rule
    )

    $requiresVariableList = @(
        ''
    )

    return ($Rule -in $requiresVariableList)
}