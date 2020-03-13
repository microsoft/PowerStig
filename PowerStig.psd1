# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

@{
# Script module or binary module file associated with this manifest.
RootModule = 'PowerStig.psm1'

# Version number of this module.
ModuleVersion = '4.2.0'

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
    @{ModuleName = 'GPRegistryPolicyDsc'; ModuleVersion = '1.0.1'},
    @{ModuleName = 'PSDscResources'; ModuleVersion = '2.10.0.0'},
    @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.4.0.0'},
    @{ModuleName = 'SqlServerDsc'; ModuleVersion = '13.3.0'},
    @{ModuleName = 'WindowsDefenderDsc'; ModuleVersion = '1.0.0.0'},
    @{ModuleName = 'xDnsServer'; ModuleVersion = '1.11.0.0'},
    @{ModuleName = 'xWebAdministration'; ModuleVersion = '2.5.0.0'}
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
    'WindowsDefender',
    'WindowsDnsServer',
    'WindowsFirewall',
    'WindowsServer'
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
        ReleaseNotes = '* Update PowerSTIG parsing for IIS 8.5 STIG - Ver 1, Rel 9: [#530](https://github.com/microsoft/PowerStig/issues/530)
        * Update PowerSTIG to successfully parse Microsoft .Net Framework STIG 4.0 STIG - Ver 1, Rel 9: [535](https://github.com/microsoft/PowerStig/issues/535)
        * Update PowerSTIG to successfully parse MS Internet Explorer 11 STIG - Ver 1, Rel 18: [#538](https://github.com/microsoft/PowerStig/issues/538)
        * Update PowerSTIG to successfully parse Mozilla Firefox STIG - Ver 4, Rel 27: [#540](https://github.com/microsoft/PowerStig/issues/540)
        * Update PowerSTIG to successfully parse Microsoft Windows 10 STIG - Ver 1, Rel 19: [533](https://github.com/microsoft/PowerStig/issues/533)
        * Update PowerSTIG to parse/convert the Windows Server 2012 R2 MS/DC V2R17/V2R18 Respectively: [531](https://github.com/microsoft/PowerStig/issues/531)
        * Update PowerSTIG to successfully parse Microsoft SQL Server 2016 Instance STIG - Ver 1, Rel 7: [#542](https://github.com/microsoft/PowerStig/issues/542)
        * Update PowerSTIG to parse and apply OfficeSystem 2013 STIG V1R9 / 2016 V1R1: [#551](https://github.com/microsoft/PowerStig/issues/551)
        * Update PowerSTIG to parse and apply Windows Server 2019 V1R2 STIG: [#554](https://github.com/microsoft/PowerStig/issues/554)
        * Fixed [#428](https://github.com/microsoft/PowerStig/issues/428): Updated JRE rule V-66941.a to be a Organizational setting
        * Fixed [#427](https://github.com/microsoft/PowerStig/issues/427): Windows 10 Rule V-63373 fails to apply settings to system drive
        * Fixed [#514](https://github.com/microsoft/PowerStig/issues/514): Feature request: additional support for servicerule properties
        * Fixed [#521](https://github.com/microsoft/PowerStig/issues/521): Organizational setting warning should include Stig name
        * Fixed [#443](https://github.com/microsoft/PowerStig/issues/443): Missing cmdlet Get-StigXccdfBenchmark function
        * Fixed [#528](https://github.com/microsoft/PowerStig/issues/528): New-StigChecklist should not require a ManualCheckFile
        * Fixed [#545](https://github.com/microsoft/PowerStig/issues/545): Need a test to verify the conversionstatus="fail" does not exist in processed STIGs
        * Fixed [#517](https://github.com/microsoft/PowerStig/issues/520): Need a test to verify the module version in the module manifest matches the DscResources.'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
