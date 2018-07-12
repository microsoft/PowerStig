# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the Group Details (GroupName and MembersToExclude) from the STIG rule check-content
    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-GroupDetail
{
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    $srcRoot = Split-Path -Path $PSScriptRoot | Split-Path
    $templateFile = Join-Path -Path $srcRoot -ChildPath 'templates\groupRuleTemplate.txt'
    $result = $CheckContent | ConvertFrom-String -TemplateFile $templateFile

    return $result
}
#endregion
