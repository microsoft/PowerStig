# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

@{
# Script module or binary module file associated with this manifest.
RootModule = 'PowerStig.psm1'

# Version number of this module.
ModuleVersion = '4.3.0'

# ID used to uniquely identify this module
GUID = 'a132f6a5-8f96-4942-be25-b213ee7e4af3'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = 'Copyright (c) Microsoft Corporation. All rights reserved.'

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
    @{ModuleName = 'AuditSystemDsc'; ModuleVersion = '1.1.0'},
    @{ModuleName = 'AccessControlDsc'; ModuleVersion = '1.4.0.0'},
    @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '6.2.0.0'},
    @{ModuleName = 'FileContentDsc'; ModuleVersion = '1.1.0.108'},
    @{ModuleName = 'GPRegistryPolicyDsc'; ModuleVersion = '1.2.0'},
    @{ModuleName = 'PSDscResources'; ModuleVersion = '2.10.0.0'},
    @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.4.0.0'},
    @{ModuleName = 'SqlServerDsc'; ModuleVersion = '13.3.0'},
    @{ModuleName = 'WindowsDefenderDsc'; ModuleVersion = '1.0.0.0'},
    @{ModuleName = 'xDnsServer'; ModuleVersion = '1.11.0.0'},
    @{ModuleName = 'xWebAdministration'; ModuleVersion = '2.5.0.0'},
    @{ModuleName = 'SharePoint'; ModuleVersion = '3.7.0.0'}
)

# DSC resources to export from this module
DscResourcesToExport = @(
    'Adobe',
    'DotNetFramework',
    'FireFox',
    'IisServer',
    'IisSite',
    'InternetExplorer',
    'McAfee',
    'Office',
    'OracleJRE',
    'SqlServer',
    'WindowsClient',
    'WindowsDefender',
    'WindowsDnsServer',
    'WindowsFirewall',
    'WindowsServer',
    'SharePoint'
)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Get-DomainName',
    'Get-Stig',
    'New-StigCheckList',
    'Get-StigRuleList',
    'Get-StigVersionNumber',
    'Get-PowerStigFilelist',
    'Split-BenchmarkId'
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
        ReleaseNotes = '* Update PowerSTIG to Expand .NET STIG Automation: [#591](https://github.com/microsoft/PowerStig/issues/591)
        * Update PowerSTIG to parse and apply McAfee VirusScan 8.8 Local Client STIG V5R16: [#588](https://github.com/microsoft/PowerStig/issues/588)
        * Update PowerSTIG to successfully parse Microsoft SQL Server 2016 Instance STIG - Ver 1, Rel 8: [#586](https://github.com/microsoft/PowerStig/issues/586)
        * Update PowerSTIG to parse and apply Windows Server 2019 V1R3 STIG: [#584](https://github.com/microsoft/PowerStig/issues/584)
        * Update PowerSTIG to parse/convert the Windows Server 2016 V2R10: [#582](https://github.com/microsoft/PowerStig/issues/582)
        * Update PowerSTIG to parse/convert the Windows Server 2012 DNS STIG V1R13: [#580](https://github.com/microsoft/PowerStig/issues/580)
        * Update PowerSTIG to to parse/convert the Windows Server 2012 R2 DC V2R19: [#578](https://github.com/microsoft/PowerStig/issues/578)
        * Update PowerSTIG to parse/convert the Windows Defender STIG V1R7: [#576](https://github.com/microsoft/PowerStig/issues/576)
        * Update PowerSTIG to successfully parse Mozilla Firefox STIG - Ver 4, Rel 28: [#573](https://github.com/microsoft/PowerStig/issues/573)
        * Update PowerSTIG to parse and apply Adobe Acrobat Reader Version 1, Release 6: [#562](https://github.com/microsoft/PowerStig/issues/562)
        * Update PowerSTIG release process to include STIG Coverage markdown wiki automation: [#560](https://github.com/microsoft/PowerStig/issues/560)
        * Update to PowerSTIG to show duplicate rule status matching in a checklist: [#257](https://github.com/microsoft/PowerStig/issues/257)
        * Fixed [#589](https://github.com/microsoft/PowerStig/issues/589): Update module manifest to leverage GPRegistryPolicyDsc v1.2.0
        * Fixed [#569](https://github.com/microsoft/PowerStig/issues/569): Update SqlServerDsc module version references
        * Fixed [#259](https://github.com/microsoft/PowerStig/issues/259): Checklist .ckl file fails XML validation in Stig Viewer 2.8.
        * Fixed [#527](https://github.com/microsoft/PowerStig/issues/527): Checklist is not using manualcheckfile when using DscResult.
        * Fixed [#548](https://github.com/microsoft/PowerStig/issues/548): Target/host data is blank when creating a new checklist.
        * Fixed [#546](https://github.com/microsoft/PowerStig/issues/546): Typecast causing an issue when trying to generate checklist using New-StigChecklist function.
        * Fixed [#401](https://github.com/microsoft/PowerStig/issues/401): Checklists generated by New-StigChecklist do not provide finding details.
        * Fixed [#593](https://github.com/microsoft/PowerStig/issues/593): Update PowerSTIG Convert naming conventions of output STIGs'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
