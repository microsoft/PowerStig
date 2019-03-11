# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

@{
# Script module or binary module file associated with this manifest.
RootModule = 'PowerStig.psm1'

# Version number of this module.
ModuleVersion = '3.0.1'

# ID used to uniquely identify this module
GUID = 'a132f6a5-8f96-4942-be25-b213ee7e4af3'

# Author of this module
Author = 'Adam Haynes'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2017 Adam Haynes. All rights reserved.'

# Description of the functionality provided by this module
Description = 'The PowerStig module provides a set of PowerShell classes to access DISA STIG settings extracted from the xccdf. The module provides a unified way to access the parsed STIG data by enabling the concepts of:
1. Exceptions (overriding and auto-documenting)
2. Ignoring a single or entire class of rules (auto-documenting)
3. Organizational settings to address STIG rules that have allowable ranges.

This module is intended to be used by additional automation as a lightweight portable “database” to audit and enforce the parsed STIG data.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
CLRVersion = '4.0'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules  = @(
    @{ModuleName = 'AuditPolicyDsc'; ModuleVersion = '1.2.0.0'},
    @{ModuleName = 'AccessControlDsc'; ModuleVersion = '1.3.0.0'},
    @{ModuleName = 'FileContentDsc'; ModuleVersion = '1.1.0.108'},
    @{ModuleName = 'PolicyFileEditor'; ModuleVersion = '3.0.1'},
    @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.4.0.0'},
    @{ModuleName = 'SqlServerDsc'; ModuleVersion = '12.1.0.0'},
    @{ModuleName = 'WindowsDefenderDsc'; ModuleVersion = '1.0.0.0'},
    @{ModuleName = 'xDnsServer'; ModuleVersion = '1.11.0.0'},
    @{ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.3.0.0'},
    @{ModuleName = 'xWebAdministration'; ModuleVersion = '2.5.0.0'},
    @{ModuleName = 'xWinEventLog'; ModuleVersion = '1.2.0.0'}
)

# DSC resources to export from this module
DscResourcesToExport = @(
    'DotNetFramework',
    'FireFox',
    'IisServer',
    'IisSite',
    'InternetExplorer',
    'Office',
    'OracleJRE',
    'SqlServer',
    'WindowsClient',
    'WindowsDnsServer',
    'WindowsFirewall',
    'WindowsServer'
)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Get-DomainName',
    'Get-Stig',
    'New-StigCheckList'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'DSC','DesiredStateConfiguration','STIG','PowerStig'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/Microsoft/PowerStig/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/Microsoft/PowerStig'

        # ReleaseNotes of this module
        ReleaseNotes = 'NEW

        * Introduces class support for each rule type
        * The STIG class now contains an array of rule objects vs xml elements
        * Orgsettings, Exceptions, and Rule skips are all supported by the Rule base class
        * Rule help is provided for any loaded rule.
          * See the [wiki](https://github.com/Microsoft/PowerStig/wiki/GettingRuleHelp) for more information.
        * Major code refactor to simplify maintenance and usage
        * [Breaking Change] The STIG class constructor no longer accepts Orgsettings, Exceptions, or Rule skips
          * That functionality has move to the load rule method
        * DSC composite resource parameter validation for version numbers has been removed
          * The STIG class validates all input and will throw an error if invalid data is provided.
        * The Get-StigList has be updated and renamed to Get-Stig to return the STIG class

        UPDATES

        * Fixed [#241](https://github.com/Microsoft/PowerStig/issues/241): [WindowsFeatureRule] PsDesiredStateConfiguration\WindowsOptionalFeature doesn''t properly handle features that return $null
        * Fixed [#258](https://github.com/Microsoft/PowerStig/issues/258): New-StigChecklist will not accept a path without an explicit filename
        * Fixed [#243](https://github.com/Microsoft/PowerStig/issues/243): [V-46515] Windows-All-IE11-1.15 Rawstring typo
        * Fixed [#289](https://github.com/Microsoft/PowerStig/issues/289): Updated DocumentRule and DocumentRuleConvert Classes to parse correctly.
        * Fixed [#284](https://github.com/Microsoft/PowerStig/issues/284): [V-74415] [V-74413] Windows 10 STIG rule V-74415 and V-74413 should not contain white space in key
        * Fixed [290](https://github.com/Microsoft/PowerStig/issues/290): [V-76731] IIS Server STIG V-76731 fails to properly set STIG guidance because rule is not split.
        * Fixed [314](https://github.com/Microsoft/PowerStig/issues/314): Update PowerSTIG to Utilize LogTargetW3C parameter in xWebAdministration 2.5.0.0.
        * Fixed [334](https://github.com/Microsoft/PowerStig/issues/334): Update PowerStig to utilize AccessControlDsc 1.3.0.0
        * Fixed [331](https://github.com/Microsoft/PowerStig/issues/331): 2012/R2 [V-39325] 2016 [V-73373], [V-73389] PermissionRule.Convert CheckContent Match Parser Update
        * Fixed [320](https://github.com/Microsoft/PowerStig/issues/320): IIS Site STIG doesn''t correctly convert STIGS that contain "SSL Settings" in raw string

        * Added the following STIGs
          * IIS Site 8.5 V1R6 [#276](https://github.com/Microsoft/PowerStig/issues/276)
          * Windows Firewall STIG V1R7 [#319](https://github.com/Microsoft/PowerStig/issues/319)

        * Removed the following STIGs
          * Windows Server 2012 R2 DC 2.12
          * Windows Server 2012 R2 DSN 1.7
          * Active Directory Domain 2.9
          * IIS Server 8.5 1.3
          * IIS Site 8.5 1.2
          * Removed: Internet Explorer 1.13'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
