# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the OptionName type from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>

function Get-OptionName
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
        {$delimiter = '(?:(?:-|>)>)'
            $PSItem -Match "(?:Expand Local Policies) $delimiter Security Options|(?:Expand ""Local Policies"") $delimiter Select ""Security Options"""}
        {
            $optionName = 'System_cryptography_Use_FIPS_compliant_algorithms_for_encryption_hashing_and_signing'
        }
    }

    return $optionName
}

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the OptionValue type from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>

function Get-OptionValue
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
        {$delimiter = '(?:(?:-|>)>)'
            $PSItem -Match "(?:Expand Local Policies) $delimiter Security Options|(?:Expand ""Local Policies"") $delimiter Select ""Security Options"""}
        {
            $optionValue = 'enabled'
        }
    }

    return $optionValue
}
