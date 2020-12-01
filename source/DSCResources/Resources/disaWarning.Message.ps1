# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if ($stig.Version -ge [version]2.1)
{
    Write-Warning -Message "With DISA's Quarterly Release (October 2020), rule Ids have changed."
    Write-Warning -Message "For more information, please visit https://aka.ms/PowerStigDisaChanges"
}
