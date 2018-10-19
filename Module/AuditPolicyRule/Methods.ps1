# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Parses Check-Content element to retrieve the Audit Policy SubCategory
#>
function Get-AuditPolicySubCategory
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

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    <#
        This is a little backwards since we don't know what subcategory we are looking for at this
        point. Grab what we assume to be a subcategory in the string and trim. Splitting with an or
        returns multiple matches and the subcategory should be at 1
    #>

    $subCategory = ( Get-AuditPolicySettings -CheckContent $CheckContent )[1].Trim()

    # Validate the subcateory that we found against the known good list
    if ( $auditPolicySubcategories.Contains( $subCategory ) )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Subcategory found : $true"
        return $subCategory
    }

    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Subcategory found : $false"
    return $null
}

<#
    .SYNOPSIS
        Parses Check-Content element to retrieve the Audit Policy SubCategory flag
#>
    function Get-AuditPolicyFlag
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

        Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

        # The audit flag should be at the second index.
        $flagString = ( Get-AuditPolicySettings -CheckContent $CheckContent )[2].Trim()

        # Validate the flag that we found against the known good list
        if ( $auditPolicyFlags.Contains( $flagString ) )
        {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Audit flag found : $true"
            return $flagString
        }

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Audit flag found : $false"
        return $null
    }

    <#
    .SYNOPSIS
        Selects the line from the Check-Content element that contains the audit policy settings
#>
    function Get-AuditPolicySettings
    {
        [CmdletBinding()]
        [OutputType([string[]])]
        param
        (
            [Parameter(Mandatory = $true)]
            [AllowEmptyString()]
            [string[]]
            $CheckContent
        )

        Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

        $auditPolicyLine = $CheckContent | Select-String -Pattern $auditPolicyRegularExpressions.AuditPolicyLine

        return $auditPolicyLine -split $auditPolicyRegularExpressions.AuditPolicySplit
    }
#endregion

