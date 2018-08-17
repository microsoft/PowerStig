# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
# Header

# This file is not currently in use, but is provided as part of the standard module structure.

# Footer
$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
Export-ModuleMember -Function '*' -Variable '*'
