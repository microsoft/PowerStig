# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'PowerStig.psm1'

    # Version number of this module.
    ModuleVersion        = '4.29.0'

    # ID used to uniquely identify this module
    GUID                 = 'a132f6a5-8f96-4942-be25-b213ee7e4af3'

    # Author of this module
    Author               = 'Microsoft Corporation'

    # Company or vendor of this module
    CompanyName          = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright            = 'Copyright (c) Microsoft Corporation. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'The PowerStig module provides a set of PowerShell classes to access DISA STIG settings extracted from the xccdf. The module provides a unified way to access the parsed STIG data by enabling the concepts of:
    1. Exceptions (overriding and auto-documenting)
    2. Ignoring a single or entire class of rules (auto-documenting)
    3. Organizational settings to address STIG rules that have allowable ranges.

    This module is intended to be used by additional automation as a lightweight portable database to audit and enforce the parsed STIG data.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    CLRVersion           = '4.0'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @(
        @{ModuleName = 'AuditPolicyDsc'; ModuleVersion = '1.4.0.0' },
        @{ModuleName = 'AuditSystemDsc'; ModuleVersion = '1.1.0' },
        @{ModuleName = 'AccessControlDsc'; ModuleVersion = '1.4.3' },
        @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '8.4.0' },
        @{ModuleName = 'FileContentDsc'; ModuleVersion = '1.3.0.151' },
        @{ModuleName = 'GPRegistryPolicyDsc'; ModuleVersion = '1.3.1' },
        @{ModuleName = 'PSDscResources'; ModuleVersion = '2.12.0.0' },
        @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.10.0.0' },
        @{ModuleName = 'SqlServerDsc'; ModuleVersion = '15.1.1' },
        @{ModuleName = 'WindowsDefenderDsc'; ModuleVersion = '2.2.0' },
        @{ModuleName = 'xDnsServer'; ModuleVersion = '1.16.0.0' },
        @{ModuleName = 'xWebAdministration'; ModuleVersion = '3.2.0' },
        @{ModuleName = 'CertificateDsc'; ModuleVersion = '5.0.0' },
        @{ModuleName = 'nx'; ModuleVersion = '1.0' }
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
    FunctionsToExport    = @(
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
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = 'DSC', 'DesiredStateConfiguration', 'STIG', 'PowerStig', 'PSModule'

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/Microsoft/PowerStig/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/Microsoft/PowerStig'

            # Prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # ReleaseNotes of this module
            ReleaseNotes = '## ## [4.29.0] - 2026-04-01
                *
                * This is a bulk add and cleanup update, Retired STIGs are being removed and this will be the last update for Sunset Stigs.  
                * 
                * Updated PowerStig to parse/apply the following STIGS
                * Sunset-Microsoft Internet Explorer 11 STIG - Ver 2, Rel 6
                * Sunset-Microsoft Access 2016 STIG - Ver 2, Rel 1
                * Sunset-Microsoft Excel 2016 STIG - Ver 2, Rel 2
                * Sunset-Microsoft OneNote 2016 STIG - Ver 2, Rel 1
                * Sunset-Microsoft Outlook 2016 STIG - Ver 2, Rel 4
                * Sunset-Microsoft PowerPoint 2016 STIG - Ver 2, Rel 1
                * Sunset-Microsoft Publisher 2016 STIG - Ver 2, Rel 1
                * Sunset-Microsoft Skype for Business 2016 STIG - Ver 2, Rel 1
                * Sunset-Microsoft Office System 2016 STIG - Ver 2, Rel 5
                * Sunset-Microsoft Word 2016 STIG - Ver 2, Rel 1
                * Sunset-Red Hat Enterprise Linux 7 STIG - Ver 3, Rel 15
                * Sunset-Canonical Ubuntu 18.04 LTS STIG - Ver 2, Rel 15
                * Sunset-Microsoft Windows 10 STIG - Ver 3, Rel 6
                * Sunset-Microsoft Windows 2012 Server Domain Name System STIG - Ver 2, Rel 7
                * Sunset-Microsoft Windows Server 2016 MS STIG - Ver 2, Rel 10
                * Sunset-Microsoft Windows Server 2016 DC STIG - Ver 2, Rel 10
                * Mozilla Firefox STIG - Ver 6, Rel 7
                * Microsoft IIS 10.0 Server STIG
                * Microsoft IIS 10.0 Site STIG
                * Microsoft Edge STIG - Ver 2, Rel 4
                * Red Hat Enterprise Linux 9 STIG - Ver 2, Rel 7
                * Microsoft SQL Server 2016 STIG
                * Microsoft SQL Server 2022 STIG
                * Microsoft Windows 11 STIG - Ver 2, Rel 6
                * Microsoft Defender Antivirus STIG - Ver 2, Rel 7
                * Microsoft Windows Server 2019 DC STIG - Ver 3, Rel 7
                * Microsoft Windows Server 2019 MS STIG - Ver 3, Rel 7
                * Microsoft Windows Server 2022 DC STIG - Ver 2, Rel 7
                * Microsoft Windows Server 2022 MS STIG - Ver 2, Rel 7
                *
                * Removed the following Retired STIGs from PowerStig - Please use 4.28.0 if needed.
                * IISServer 8.5
                * IISSite 8.5
                * McAfee 8.8 VirusScan
                * Office Excel2013
                * Office Outlook2013
                * Office PowerPoint2013
                * Office System2013
                * Office Visio2013
                * Office Word2013
                * OracleJRE 8
                * SqlServer 2012 Database
                * SqlServer 2012 Instance
                * Vsphere 6.5
                * WindowsServer 2012R2 DC
                * WindowsServer 2012R2 MS '
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
