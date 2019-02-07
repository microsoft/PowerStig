# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

@{
# Script module or binary module file associated with this manifest.
RootModule = 'PowerStig.psm1'

# Version number of this module.
ModuleVersion = '2.4.0.0'

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
    @{ModuleName = 'AccessControlDsc'; ModuleVersion = '1.2.0.0'},
    @{ModuleName = 'FileContentDsc'; ModuleVersion = '1.1.0.108'},
    @{ModuleName = 'PolicyFileEditor'; ModuleVersion = '3.0.1'},
    @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.4.0.0'},
    @{ModuleName = 'SqlServerDsc'; ModuleVersion = '12.1.0.0'},
    @{ModuleName = 'WindowsDefenderDsc'; ModuleVersion = '1.0.0.0'},
    @{ModuleName = 'xDnsServer'; ModuleVersion = '1.11.0.0'},
    @{ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.3.0.0'},
    @{ModuleName = 'xWebAdministration'; ModuleVersion = '2.3.0.0'},
    @{ModuleName = 'xWinEventLog'; ModuleVersion = '1.2.0.0'}
)

# DSC resources to export from this module
DscResourcesToExport = @(
    'Browser',
    'DotNetFramework',
    'FireFox',
    'IisServer',
    'IisSite',
    'Office',
    'OracleJRE',
    'SqlServer',
    'WindowsClient'
    'WindowsDnsServer',
    'WindowsFirewall',
    'WindowsServer'
)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Get-OrgSettingsObject',
    'Get-DomainName',
    'Get-StigList',
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
        ReleaseNotes = '* Fixed [#244](https://github.com/Microsoft/PowerStig/issues/244): IIS Server rule V-76727.b org setting test fails
* Fixed [#246](https://github.com/Microsoft/PowerStig/issues/246): IIS Server rule V-76737 contains an incorrect value
* Fixed [#225](https://github.com/Microsoft/PowerStig/issues/225): Update PowerStig integration tests to consolidate duplicate code.
* Fixed [#160](https://github.com/Microsoft/PowerStig/issues/160): PowerStig.Convert needs to handle new registry rules without affecting existing code
* Fixed [#201](https://github.com/Microsoft/PowerStig/issues/201): Update PowerStig integration tests to account for skips and exceptions.
* Fixed [#260](https://github.com/Microsoft/PowerStig/issues/260): FireFox Composite Resource configuration applies correctly, but never passes a Test-DscConfiguration.
* Fixed [#244](https://github.com/Microsoft/PowerStig/issues/244): IIS Server rule V-76727.b org setting test fails
* Fixed [#265](https://github.com/Microsoft/PowerStig/issues/265): Fixed UserRightsAssignment split rule bug.
* Fixed [#267](https://github.com/Microsoft/PowerStig/issues/267): Fixed winlogon registry path parser bug.
* Fixed [#238](https://github.com/Microsoft/PowerStig/issues/238): Adds regex tracker for RegistryRule regex's.
* Fixed [#274](https://github.com/Microsoft/PowerStig/issues/274): UserRightsAssignment composite resource does not leverage the Force Parameter.
* Fixed [#280](https://github.com/Microsoft/PowerStig/issues/280): HKEY_CURRENT_USER is not needed with the cAdministrativeTemplateSetting composite resource.

* Windows Server 2012R2 Fixes
  * V-36707 is now an org setting
  * (DC only) V-2376 - V-2380 are migrated from manual to account policy rules.

* Added the following STIGs
  * SQL Server 2016 Instance V1R3 [#186](https://github.com/Microsoft/PowerStig/issues/186)
  * Windows Defender Antivirus V1R4 [#236](https://github.com/microsoft/PowerStig/issues/236)
  * Mozilla Firefox V4R24 [#261](https://github.com/Microsoft/PowerStig/issues/261)
  * Windows Server 2016 V1R6 [#169](https://github.com/Microsoft/PowerStig/issues/169)
  * Windows Server 2016 V1R7 [#251](https://github.com/Microsoft/PowerStig/issues/251)
  * SQL Server 2012 Database V1R18 [#263](https://github.com/Microsoft/PowerStig/issues/263)
  * Windows Server 2012R2 DC V2R15 [#267](https://github.com/Microsoft/PowerStig/issues/267)
  * Windows 10 V1R16 [#269](https://github.com/Microsoft/PowerStig/issues/269)
  * IIS Server 8.5 V1R6 [#256](https://github.com/Microsoft/PowerStig/issues/266)
  * Windows Server 2016 V1R6 [#169](https://github.com/Microsoft/PowerStig/issues/169)
  * Windows Server 2016 V1R7 [#251](https://github.com/Microsoft/PowerStig/issues/251)
  * Windows Server 2012R2 DNS V1R11 STIG [#265](https://github.com/Microsoft/PowerStig/issues/265)
  * AD Domain V2R12 [#270](https://github.com/Microsoft/PowerStig/issues/270)'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
