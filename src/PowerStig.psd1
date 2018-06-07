# // Copyright (c) Microsoft Corporation. All rights reserved.// Licensed under the MIT license.

@{
# Script module or binary module file associated with this manifest.
RootModule = 'PowerStig.psm1'

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = 'a132f6a5-8f96-4942-be25-b213ee7e4af3'

# Author of this module
Author = 'Adam Haynes'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2017 Adam Haynes. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Module for managing the DISA STIGs'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
CLRVersion = '4.0'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Get-OrgSettingsObject', 'Get-DomainName', 'Get-StigList'

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
        ReleaseNotes = 'STIGs added:
        Windows Server 2012R2 MS STIG V2R12
        Windows Server 2012R2 DC STIG V2R12
        Windows Server DNS V1R9
        Windows AD Domain V2R9
        IE11 V1R15
        '
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
