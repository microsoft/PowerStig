# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

@{
# Script module or binary module file associated with this manifest.
RootModule = 'PowerStig.psm1'

# Version number of this module.
ModuleVersion = '3.2.0'

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
    @{ModuleName = 'AuditSystemDsc'; ModuleVersion = '1.0.0.0'},
    @{ModuleName = 'AccessControlDsc'; ModuleVersion = '1.4.0.0'},
    @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '6.2.0.0'},
    @{ModuleName = 'FileContentDsc'; ModuleVersion = '1.1.0.108'},
    @{ModuleName = 'PolicyFileEditor'; ModuleVersion = '3.0.1'},
    @{ModuleName = 'PSDscResources'; ModuleVersion = '2.10.0.0'},
    @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.4.0.0'},
    @{ModuleName = 'SqlServerDsc'; ModuleVersion = '12.1.0.0'},
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
        ReleaseNotes = '* Added support for IIS 8.5 Server STIG, Version 1, Release 7 [#399](https://github.com/Microsoft/PowerStig/issues/399)
        * Fixed [#373](https://github.com/Microsoft/PowerStig/issues/373): Registry resource does not handle null values for ValueData contained in Processed STIGs
        * Fixed [#376](https://github.com/Microsoft/PowerStig/issues/376): SQL STIG Rules V-41021 (Instance STIG) and V-41402 (Database STIG) fail to apply when applying to a SQL instance that is NOT name the default (MSSQLSERVER).
        * Fixed [#377](https://github.com/Microsoft/PowerStig/issues/377): SQL Instance Rule V-40936 fails when Set-TargertResource is ran
        * Fixed [#280](https://github.com/Microsoft/PowerStig/issues/280): HKEY_CURRENT_USER is not needed with the cAdministrativeTemplateSetting composite resource. (Regression Issue)
        * Fixed [#385](https://github.com/Microsoft/PowerStig/issues/385): IIS Server STIG V-76681 does not parse correctly
        * Added support for Office 2016 STIGs [#370](https://github.com/Microsoft/PowerStig/issues/370)
        * Added support to Automate Application Pool Recycling for IisSite_8.5 [#378](https://github.com/Microsoft/PowerStig/issues/378)
        * Added support for Windows Server 2012R2 DC V2R16 [#398](https://github.com/Microsoft/PowerStig/issues/398)
        * Added support for update Windows Server 2012 MS STIG v2r15 [#395](https://github.com/Microsoft/PowerStig/issues/395)
        * Added support for Firefox STIG v4r25 [#389](https://github.com/Microsoft/PowerStig/issues/389)
        * Added entry in log file for IISSite 1.7 so rule v-76819 parses as an xWebConfigurationProperty [#407](https://github.com/microsoft/PowerStig/issues/407)
        * Added IISSite v1.7 [#400](https://github.com/microsoft/PowerStig/issues/400)
        * Fixed [#403](https://github.com/microsoft/PowerStig/issues/403): DotNet STIG V1R7 update'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
