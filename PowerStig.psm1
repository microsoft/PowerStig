# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module .\Module\Common\Common.psm1
using module .\Module\Stig.OrganizationalSetting\Stig.OrganizationalSetting.psm1
using module .\Module\Stig.SkippedRule\Stig.SkippedRule.psm1
using module .\Module\Stig.SkippedRuleType\Stig.SkippedRuleType.psm1
using module .\Module\Stig.StigData\Stig.StigData.psm1
using module .\Module\Stig.StigException\Stig.StigException.psm1
using module .\Module\Stig.TechnologyRole\Stig.TechnologyRole.psm1
using module .\Module\Stig.TechnologyVersion\Stig.TechnologyVersion.psm1

# load the public StigData functions

$pathList = @(
    "$PSScriptRoot\Module\Stig.Main",
    "$PSScriptRoot\Module\STIG.Checklist"
)
foreach ($supportFile in (Get-ChildItem -Path $pathList -Filter '*.ps1'))
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
