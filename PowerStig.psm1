# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# load the public functions
foreach ($supportFile in (Get-ChildItem -Path "$PSScriptRoot\Module\Stig" -Filter '*.ps1'))
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}

Export-ModuleMember -Function @(
    'Get-OrgSettingsObject',
    'Get-DomainName',
    'Get-StigList',
    'New-StigCheckList'
)
