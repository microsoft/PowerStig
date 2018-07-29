#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
#endregion
#region Class

# This file is not currently in use, but is provided as part of the standard module structure.

#endregion
#region Footer
Foreach ($supportFile in (Get-ChildItem -Path $PSScriptRoot -Exclude $MyInvocation.MyCommand.Name))
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
Export-ModuleMember -Function '*' -Variable '*'
#endregion
