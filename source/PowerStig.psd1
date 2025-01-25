# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PowerStig.psm1'

    # Version number of this module.
    ModuleVersion = '4.24.0'

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

    This module is intended to be used by additional automation as a lightweight portable database to audit and enforce the parsed STIG data.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    CLRVersion = '4.0'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules  = @(
        @{ModuleName = 'AuditPolicyDsc'; ModuleVersion = '1.4.0.0'},
        @{ModuleName = 'AuditSystemDsc'; ModuleVersion = '1.1.0'},
        @{ModuleName = 'AccessControlDsc'; ModuleVersion = '1.4.3'},
        @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '8.4.0'},
        @{ModuleName = 'FileContentDsc'; ModuleVersion = '1.3.0.151'},
        @{ModuleName = 'GPRegistryPolicyDsc'; ModuleVersion = '1.3.1'},
        @{ModuleName = 'PSDscResources'; ModuleVersion = '2.12.0.0'},
        @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.10.0.0'},
        @{ModuleName = 'SqlServerDsc'; ModuleVersion = '17.0.0'},
        @{ModuleName = 'WindowsDefenderDsc'; ModuleVersion = '2.2.0'},
        @{ModuleName = 'xDnsServer'; ModuleVersion = '1.16.0.0'},
        @{ModuleName = 'xWebAdministration'; ModuleVersion = '3.2.0'},
        @{ModuleName = 'CertificateDsc'; ModuleVersion = '5.0.0'},
        @{ModuleName = 'nx'; ModuleVersion = '1.0'}
    )

    # DSC resources to export from this module
    DscResourcesToExport = @(
        'Adobe',
        'DotNetFramework',
        'FireFox',
        'IisServer',
        'IisSite',
        'InternetExplorer',
        'Chrome',
        'McAfee',
        'Office',
        'OracleJRE',
        'OracleLinux',
        'SqlServer',
        'WindowsClient',
        'WindowsDefender',
        'WindowsDnsServer',
        'WindowsFirewall',
        'WindowsServer',
        'Vsphere',
        'RHEL',
        'Ubuntu',
        'Edge'
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-DomainName',
        'Get-Stig',
        'New-StigCheckList',
        'Get-StigRuleList',
        'Get-StigVersionNumber',
        'Get-PowerStigFilelist',
        'Split-BenchmarkId',
        'Get-StigRule',
        'Get-StigRuleExceptionString',
        'Backup-StigSettings',
        'Restore-StigSettings'
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
            Tags = 'DSC','DesiredStateConfiguration','STIG','PowerStig', 'PSModule'

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/Microsoft/PowerStig/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/Microsoft/PowerStig'

            # Prerelease string value if the release should be a prerelease.
            Prerelease = ''

            # ReleaseNotes of this module
            ReleaseNotes = '## [4.23.0] - 2024-09-11
                * Update Powerstig to parse\apply Oracle Linux 8 STIG - Ver 2, Rel 1 [#1380](https://github.com/microsoft/PowerStig/issues/1380)
                * Update Powerstig to parse\apply Microsoft Windows Server 2019 STIG - Ver 3, Rel 1 [#1369](https://github.com/microsoft/PowerStig/issues/1369)
                * Update Powerstig to parse\apply Microsoft Windows Server 2022 STIG - Ver 2, Rel 1 [#1370](https://github.com/microsoft/PowerStig/issues/1370)
                * Update Powerstig to parse\apply U_MS_SQL_Server_2016_Instance_V3R1_Manual_STIG [#1373](https://github.com/microsoft/PowerStig/issues/1373)
                * Update Powerstig to parse\apply Microsoft IIS 10.0 Server STIG [#1371](https://github.com/microsoft/PowerStig/issues/1371)
                * Update Powerstig to parse\apply Microsoft Office 365 ProPlus STIG - Ver 3, Rel 1 [#1372](https://github.com/microsoft/PowerStig/issues/1372)
                * Update Powerstig to parse\apply Microsoft Windows 11 STIG - Ver 2, Rel 1 [#1368](https://github.com/microsoft/PowerStig/issues/1368)
                * Update Powerstig to parse\apply Microsoft Windows 10 STIG - Ver 3, Rel 1 [#1366](https://github.com/microsoft/PowerStig/issues/1366)
                * Update Powerstig to parse/apply Microsoft Edge STIG - Ver 2, Rel 1 [#1364](https://github.com/microsoft/PowerStig/issues/1350)'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
