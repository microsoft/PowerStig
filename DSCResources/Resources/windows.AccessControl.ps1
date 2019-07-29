# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type PermissionRule

foreach ( $rule in $rules )
{
    # Determine PermissionRule type and handle
    Switch ($rule.dscresource)
    {
        'RegistryAccessEntry'
        {
            RegistryAccessEntry (Get-ResourceTitle -Rule $rule)
            {
                Path = $rule.Path
                Force = [bool]$rule.Force
                AccessControlList = $(

                    foreach ($acentry in $rule.AccessControlEntry.Entry)
                    {
                        AccessControlList
                        {
                            Principal = $acentry.Principal
                            ForcePrincipal = [bool]$rule.ForcePrincipal
                            AccessControlEntry = @(
                                AccessControlEntry
                                {
                                    AccessControlType = $(
                                        if (-not ([string]::IsNullOrEmpty($acentry.Type)))
                                        {
                                            $acentry.Type
                                        }
                                        else
                                        {
                                            'Allow'
                                        }
                                    )
                                    Inheritance = $(
                                        if (-not ([string]::IsNullOrEmpty($acentry.Inheritance)))
                                        {
                                            $acentry.Inheritance
                                        }
                                        else
                                        {
                                            'This Key and Subkeys'
                                        }
                                    )
                                    Rights = $acentry.Rights.Split(',')
                                    Ensure = 'Present'
                                }
                            )
                        }
                    }
                )
            }
            break
        }
        'NTFSAccessEntry'
        {
            NTFSAccessEntry (Get-ResourceTitle -Rule $rule)
            {
                Path = $rule.Path
                Force = [bool]$rule.Force
                AccessControlList = $(
                    foreach ($acentry in $rule.AccessControlEntry.Entry)
                    {
                        NTFSAccessControlList
                        {
                            Principal = $acentry.Principal
                            ForcePrincipal = [bool]$rule.ForcePrincipal
                            AccessControlEntry = @(
                                NTFSAccessControlEntry
                                {
                                    AccessControlType = $(
                                        if (-not ([string]::IsNullOrEmpty($acentry.Type)))
                                        {
                                            $acentry.Type
                                        }
                                        else
                                        {
                                            'Allow'
                                        }
                                    )
                                    Inheritance = $(
                                        if (-not ([string]::IsNullOrEmpty($acentry.Inheritance)))
                                        {
                                            $acentry.Inheritance
                                        }
                                        else
                                        {
                                            'This folder only'
                                        }
                                    )
                                    FileSystemRights = $acentry.Rights.Split(',')
                                    Ensure = 'Present'
                                }
                            )
                        }
                    }
                )
            }
            break
        }
        'FileSystemAuditRuleEntry'
        {
            FileSystemAuditRuleEntry (Get-ResourceTitle -Rule $rule)
            {
                Path          = $rule.Path
                Force         = [bool]$rule.Force
                AuditRuleList = @(
                    foreach ($acentry in $rule.AccessControlEntry.Entry)
                    {
                        FileSystemAuditRuleList
                        {
                            Principal = $acentry.Principal
                            ForcePrincipal = $false
                            AuditRuleEntry = @(
                                FileSystemAuditRule
                                {
                                    AuditFlags = 'Success'
                                    FileSystemRights = $acentry.Rights.Split(',')
                                    Inheritance = $(
                                        if (-not ([string]::IsNullOrEmpty($acentry.Inheritance)))
                                        {
                                            $acentry.Inheritance
                                        }
                                        else
                                        {
                                            'This folder only'
                                        }
                                    )
                                    Ensure = 'Present'
                                }
                                FileSystemAuditRule
                                {
                                    AuditFlags = 'Failure'
                                    FileSystemRights = $acentry.Rights.Split(',')
                                    Inheritance = $(
                                        if (-not ([string]::IsNullOrEmpty($acentry.Inheritance)))
                                        {
                                            $acentry.Inheritance
                                        }
                                        else
                                        {
                                            'This folder only'
                                        }
                                    )
                                    Ensure = 'Present'
                                }
                            )
                        }
                    }
                )
            }
            break
        }
    }
}
