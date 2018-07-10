# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module .\Module\Common\Common.psm1
using module .\Module\Stig.OrganizationalSetting\Stig.OrganizationalSetting.psm1
using module .\Module\Stig.SkippedRule\Stig.SkippedRule.psm1
using module .\Module\Stig.SkippedRuleType\Stig.SkippedRuleType.psm1
using module .\Module\Stig.StigException\Stig.StigException.psm1
using module .\Module\Stig.TechnologyRole\Stig.TechnologyRole.psm1
using module .\Module\Stig.TechnologyVersion\Stig.TechnologyVersion.psm1

Write-Verbose "$(Get-Module 'STIG.*')"
# load the public functions
Foreach ($supportFile in ( Get-ChildItem -Path "$PSScriptRoot\Module\Stig.Main" -Filter '*.ps1' ) )
{
    Write-Verbose "Loading $($supportFile.FullName)" -Verbose
    . $supportFile.FullName
}

Export-ModuleMember -Function @('Get-OrgSettingsObject', 'Get-DomainName', 'Get-StigList')

