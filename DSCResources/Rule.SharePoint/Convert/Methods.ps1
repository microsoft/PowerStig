# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

#Begin Document region

<#
        .SYNOPSIS
            This is a placeholder for the SharePointGetScript block.
        
        .DESCRIPTION
            
        
        .PARAMETER CheckContent
            
#>

function Get-SharePointGetScript
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

    return
}

<#
    .SYNOPSIS
        Placeholder for SharePointRuleTestScript

    .DESCRIPTION
        
    .PARAMETER CheckContent
        
#>

function Get-SharePointTestScript
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

        return
    
}

<#
    .SYNOPSIS Get-SharePointRuleSetScript
        Placeholder for SharePointRuleSetScript
    .DESCRIPTION
        
    .PARAMETER FixText
        

    .PARAMETER CheckContent
        
#>

function Get-SharePointSetScript
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

        return
}

#End SharePoint region

#Begin Permissions region

<#
    .SYNOPSIS
        This is a placeholder for PermissionRuleGetScript

    .DESCRIPTION
        

    .PARAMETER CheckContent
        
#>

function Get-PermissionGetScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )
   
    $queries = Get-Query -CheckContent $CheckContent

    $return = $queries[0]

    if ($return -notmatch ";$")
    {
        $return = $return + ";"
    }

    return $return
}

<#
    .SYNOPSIS
        This is a placeholder for PermissionRuleTestScript

    .DESCRIPTION
        

    .PARAMETER CheckContent
        
#>
function Get-PermissionTestScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    $queries = Get-Query -CheckContent $CheckContent

    $return = $queries[0]

    if ($return -notmatch ";$")
    {
        $return = $return + ";"
    }

    return $return
}

<#
    .SYNOPSIS
        This is a placeholder for PermissionSetScript

    .DESCRIPTION
        

    .PARAMETER FixText
        

    .PARAMETER CheckContent
        
#>
function Get-PermissionSetScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [string[]]
        $FixText,

        [Parameter()]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    $permission = ((Get-Query -CheckContent $CheckContent)[0] -split "'")[1] #Get the permission that will be set
    <#
        The following lines of code should create variables containing values that change the content from what was returned from the Get block based on the results from the Test block.
    #>

    

    return $permission
}

#End Permissions region

#Begin SPIrmSettingsRule region

<#
        .SYNOPSIS
            This is a placeholder for the SPIrmSettingsRuleGetScript block.
        
        .DESCRIPTION
            
        
        .PARAMETER CheckContent
            
#>

function Get-SPIrmSettingsGetScript
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

    return
}

<#
        .SYNOPSIS
            This is a placeholder for the SPIrmSettingsRuleSetScript block.
        
        .DESCRIPTION
            
        
        .PARAMETER CheckContent
            
#>

function Get-SPIrmSettingsSetScript
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

    return
}

<#
        .SYNOPSIS
            This is a placeholder for the SPIrmSettingsRuleTestScript block.
        
        .DESCRIPTION
            
        
        .PARAMETER CheckContent
            
#>

function Get-SPIrmSettingsTestScript
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

    return
}

#End SPIrmSettingsRule region

#Begin SPSiteRule region

function Get-SPSiteGetScript
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

    return
}

function Get-SPSiteSetScript
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

    return
}

function Get-SPSiteTestScript
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

    return
}

#End SPSiteRule region

#Begin SqlServerRole region
function Get-SqlServerRoleGetScript
{
    [CmdletBinding()]
    [OutputTYpe([string])]
    [CmdletBinding()]
    [CmdletBinding()]
    param (
        [Parameter()]
        [AllowEmptyString()]
        [string[]]
        $FixText,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        $CheckContent
    )
}

function Get-SqlServerRoleSetScript
{
    [CmdletBinding()]
    [OutputTYpe([string])]
    [CmdletBinding()]
    [CmdletBinding()]
    param (
        [Parameter()]
        [AllowEmptyString()]
        [string[]]
        $FixText,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        $CheckContent
    )
}

function Get-SqlServerRoleTestScript
{
    [CmdletBinding()]
    [OutputTYpe([string])]
    [CmdletBinding()]
    [CmdletBinding()]
    param (
        [Parameter()]
        [AllowEmptyString()]
        [string[]]
        $FixText,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        $CheckContent
    )
}

#End SqlServerRole region
#>

#Begin Manual region



#End Manual region

#Begin RuleType region

<#
    .SYNOPSIS
        Labels a rule as a specific type to retrieve the proper script used to enforce the STIG rule.

    .DESCRIPTION
        This functions labels a rule as a specific type so the proper scripts can dynamically be retrieved.

    .PARAMETER CheckContent
        This is the 'CheckContent' derived from the STIG raw string and holds the query that will be returned
#>

function Get-SharePointRuleSubType
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
            $ruleType = "SharePoint"
        }

        <# {
            $PSItem -Match "Active Directory Users and Computers" -or #V-59997, V-60001
            $PSItem -Match "WSS_RESTRICTED_WPG" #V-60391
        }
        {
            $ruleType = "ActiveDirectoryDsc"
        }

        {
            $PSItem -Match "SQL Server Management Console" #V-59999, V-60003
        }
        {
            $ruleType = "SqlServerDsc" #SqlServerDsc > ServerRole
        }

        {
            $PSItem -Match "Configure information rights management" -or #V-59941, 59945, 59947, 59973
            $PSItem -Match "isolation boundary" #V-59981, V-59983
        }
        {
            $ruleType = "SPIrmSettings"
        }
         #>
        
        <#
            Default parser if not caught before now - if we end up here we haven't trapped for the rule sub-type.
            These should be able to get, test, set via Get-Query cleanly
        #>
        default
        {
            $ruleType = 'Manual'
        }
    }

    return $ruleType
}

#End RuleType region

#Begin Helper function region

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

#End Helpfer function region