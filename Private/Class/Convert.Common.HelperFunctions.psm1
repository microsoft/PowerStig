#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#endregion
#region Support Functions
<#
    .SYNOPSIS
        Appends the next letter in the alphabet to the ID to handle rules that enforce multiple settings
#>
function Get-AvailableId
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Id
    )

    $usedID = $global:stigSettings | Where-Object -FilterScript { $PSItem.Id -match $ID } |
            Sort-Object -Property Id

    if ( $null -eq $usedID )
    {
        return $id
    }
    else
    {
        $startInt = 96
        # 97 is ascii the char 'a' lets start with 96 so the second rule with the same id get appended with a letter

        $appendLetterInt = $startInt + $usedID.count

        return "$ID.$([char]$appendLetterInt)"
    }
}
#endregion
