# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the SqlLogin type from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-LoginType
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkcontent) 
    {
        {$PSItem -Match "Check for use of SQL Server Authentication:"}
        {
            $loginType = 'SqlLogin'
        }
    }

    return $loginType
}

<#
    .SYNOPSIS
        Sets the SqlLogin password complexity rules from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Set-PasswordPolicy
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match "Check for use of SQL Server Authentication:"}
        {
            $passwordPolicy = $true
        }
    }

    return $passwordPolicy
}

<#
    .SYNOPSIS
        Sets the SqlLogin password expiration from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Set-PasswordExpiration
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match "Check for use of SQL Server Authentication:"}
        {
            $passwordExpiration = $true
        }
    }

    return $passwordExpiration
}

<#
    .SYNOPSIS
        Sets the SqlLogin change password setting from the check-content element in the xccdf. Must be false for existing sql logins

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Set-ChangePassword
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match "Check for use of SQL Server Authentication:"}
        {
            $changePassword = $false
        }
    }

    return $changePassword
}