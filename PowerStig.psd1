# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

@{
# Script module or binary module file associated with this manifest.
RootModule = 'PowerStig.psm1'

# Version number of this module.
ModuleVersion = '4.0.0'

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
    @{ModuleName = 'GPRegistryPolicyDsc'; ModuleVersion = '1.0.0'},
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
        ReleaseNotes = '* Update PowerSTIG parsing for Windows Sever 2016 STIG - Ver 1, Rel 9 [#498] (https://github.com/microsoft/PowerStig/issues/498)
        * Fixed [#507](https://github.com/microsoft/PowerStig/issues/507): Get-HardCodedRuleLogFileEntry Errors on RegistryRule
        * Update PowerSTIG to leverage the GPRegistryPolicyDsc resource for Local Group Policy automation: [#497](https://github.com/microsoft/PowerStig/issues/497)
        * Update PowerSTIG to enable the logfile framework to consume a hashtable for HardCodedRule: [#494](https://github.com/microsoft/PowerStig/issues/494)
        * Update PowerSTIG to pass OrgSettings in via configuration hashtable: [#372](https://github.com/microsoft/PowerStig/issues/372)
        * Update support for SQL Server 2012 Database STIG, Version 1, Release 19 [#482](https://github.com/microsoft/PowerStig/issues/482)
        * Fixed [#478](https://github.com/microsoft/PowerStig/issues/478): SQL STIG Instance V-40936 Fails to apply
        * Update PowerSTIG to automate applying the IIS 8.5 STIG, Version 1 Release 8. [#469](https://github.com/microsoft/PowerStig/issues/469)
        * Fixed [#476](https://github.com/microsoft/PowerStig/issues/476): AuditSetting Rule for Windows STIGs has an incorrect operator when evaluating Service Pack information
        * Added support for Dot Net Framework 4.0 STIG, Version 1, Release 8 [#447](https://github.com/microsoft/PowerStig/issues/447)
        * Added support for Windows 10 STIG, Version 1, Release 17 & 18: [#466](https://github.com/microsoft/PowerStig/issues/466)
        * Added support for Windows 2012 Server DNS STIG, Version 1, Release 12 [#464](https://github.com/microsoft/PowerStig/issues/464)
        * Update PowerSTIG to automate applying the Windows Server 2012R2 DC & MS STIG, Version 2, Release 17 & 16 respectively. [#456](https://github.com/microsoft/PowerStig/issues/456)
        * Fixed [#444](https://github.com/microsoft/PowerStig/issues/444): Duplicate principals in Permission Rule (Registry)
        * Updated logfile in 2012R2 DC STIG leveraging HardCodedRule to automate additional STIG rules. [#446](https://github.com/microsoft/PowerStig/issues/446)
        * Updated logfile in 2012R2 MS STIG leveraging HardCodedRule to automate additional STIG rules. [#448](https://github.com/microsoft/PowerStig/issues/448)
        * Declarative definition of a rule in the StigData log file to provide a standard way to populate unautomated rules [#435](https://github.com/microsoft/PowerStig/issues/435)
        * Updated PowerSTIG to leverage AuditSetting instead of the Script resource. Additionally renamed WmiRule to AuditSettingRule [#431](https://github.com/Microsoft/PowerStig/issues/431)
        * Fixed [#419](https://github.com/Microsoft/PowerStig/issues/419): PowerStig is creating resource xSSLSettings with the wrong value for Name.
        * Added support for Windows Defender, Version 1, Release 5 [#393](https://github.com/microsoft/PowerStig/issues/393)
        * Added support for Internet Explorer 11 Version 1, Release 17 [#422](https://github.com/Microsoft/PowerStig/issues/422)
        * Added support for Server 2016 STIG, Version 1, Release 8 [#418](https://github.com/Microsoft/PowerStig/issues/418)
        * Update PowerSTIG to enforce additional rules in the SQL Server 2012 STIG [#438](https://github.com/microsoft/PowerStig/issues/438)
        * Added support for Windows Defender Antivirus STIG, Version 1, Release 6 [#462](https://github.com/Microsoft/PowerStig/issues/462)
        * Added support for Firefox STIG v4r26 [#458](https://github.com/Microsoft/PowerStig/issues/458)
        * Updated logfile in DotNet Framework STIG leveraging HardCodedRule to automate additional STIG rules. [#454](https://github.com/microsoft/PowerStig/issues/454)
        * Fixed [#493](https://github.com/microsoft/PowerStig/issues/493): IIS 8/5 Server STIG rule V-76745 is referencing the incorrect IIS default path
        * Fixed [#505](https://github.com/microsoft/PowerStig/issues/505): Missing reg key setting on V-76759 IIS Server 8.5 v1R7'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
