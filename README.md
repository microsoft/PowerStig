# PowerSTIG

**PowerStig** is a PowerShell module that contains several components to automate different DISA Security Technical Implementation Guides (STIGs) where possible.

|Name|Description|Published to PS Gallery|
| ---- | ---- | --- |
|[PowerStig.Convert](#powerstigconvert) | Extract configuration objects from the xccdf | No
|[PowerStig.Data](#powerstigdata) | A PowerShell class to access the PowerSTIG "database" | Yes
|[PowerStig.DSC](#powerstigdsc) | Compsite DSC resources to apply and/or audit STIG settings | Yes
|[PowerStig.Document](#powerstigdocument) | An experimental module to create prefilled out checklists | Yes

This project has adopted the [Microsoft Open Source Code of Conduct](
  https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](
  https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions
or comments.

|Branch|Status|Description|
| ---- | ---- | --- |
| master | [![Build status](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/master?svg=true)](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/master?svg=true) | Ccontains the latest release - no contributions are made directly to this branch. |
| dev | [![Build status](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/dev?svg=true)](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/dev?svg=true) | Where contributions should be proposed by contributors as pull requests. This branch is merged into the master branch, and be released to PowerShell Gallery. |

## Released Module

To see the released PowerStig module, go to the [PowerShell Gallery](https://www.powershellgallery.com/items?q=powerstig&x=19&y=15). We recommend that you use PowerShellGet to install PowerStig:

For example:

```powershell
Install-Module -Name PowerStig -Scope CurrentUuer
```

Once PowerStig is installed, you can view the list of STIGs that are currently available.
The Get-StigList function queries the StigData and returns a full list.
This will give you an idea of what you can target in your environment.

```powershell
Import-Module PowerStig
Get-StigList
```

To update a previously installed module use this command:

```powershell
Update-Module -Name PowerStig
```

## PowerStig.Convert

PowerStig.Convert is a utility module that we use to generate PowerStig XML to store in [PowerStig.Data](#powerstigdata).
The module uses PowerShell classes to extract settings from check-content elements of the xccdf.
This nested module is NOT published to the PS Gallery.
The extracted settings are converted into and new PowerStig XML schema.
The XML file is saved into a processed StigData folder and released to the PS Gallery on a regular cadence.

For detailed information, please see the [Convert Wiki](https://github.com/Microsoft/PowerStig/wiki/Convert)

## PowerStig.Data

PowerStig.Data is a module with PowerShell classes and a directory of PowerStig XML to provide a way of retrieving StigData and documenting deviations.
The PowerStig.Data classes provide methods to:

1. Override a setting defined in a STIG and automatically document the exception to policy
1. Apply settings that have a valid range of values (Organizational Settings)
1. Exclude a rule if it is already defined in another STIG (de-duplication) and automatically document the exception to policy
1. Exclude an entire class of rules (intended for testing and integration) and automatically document the exception to policy

For detailed information, please see the [StigData Wiki](https://github.com/Microsoft/PowerStig/wiki/Stig)

## PowerStig.DSC

PowerShell Desired State Configuration (DSC) composite resources to manage the configurable items.
Each composite uses [PowerStig.Data](#powerstigdata) as it's data source.
This allows exceptions, Org settings, and skips to be applied uniformly across all composite resources.

### Composite Resources

|Name|Description|
| ---- | --- |
|[Browser](https://github.com/Microsoft/PowerStig/wiki/Browser) | Provides a mechanism to manage Browser STIG settings. |
|[DotNetFramework](https://github.com/Microsoft/PowerStig/wiki/DotNetFramework) | Provides a mechanism to manage .Net Framework STIG settings. |
|[SqlServer](https://github.com/Microsoft/PowerStig/wiki/SqlServer) | Provides a mechanism to manage SqlServer STIG settings. |
|[WindowsDnsServer](https://github.com/Microsoft/PowerStig/wiki/WindowsDnsServer) | Provides a mechanism to manage Windows DNS Server STIG settings. |
|[WindowsFirewall](https://github.com/Microsoft/PowerStig/wiki/WindowsFirewall) | Provides a mechanism to manage the Windows Firewall STIG settings. |
|[WindowsServer](https://github.com/Microsoft/PowerStig/wiki/WindowsServer) | Provides a mechanism to manage the Windows Server STIG settings. |

For detailed information, please see the [Composite Resources Wiki](https://github.com/Microsoft/PowerStig/wiki/CompositeResources)

## PowerStig.Document

An **Experimental** module to create checklists and other types of documentation based on the results of the DSC compliance report.
This module generates a checklist, but we are not 100% sure on the workflow, so we wanted to publish the idea and build on it.

For detailed information, please see the [Document Wiki](https://github.com/Microsoft/PowerStig/wiki/Document)

## Contributing

You are more than welcome to contribute to the development of PowerStig.
There are several different ways you can help.
You can create new convert modules, add test automation, improve documentation, fix existing issues, or open new ones.
See our [contributing guide](README.CONTRIBUTING.md) for more info on how to become a contributor.
If you would like to contribute to a Composite Resource, please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md).

Thank you to everyone that has reviewed the project and provided feedback through issues.
We are especially thankful for those who have contributed pull requests to the code and documentation.

### Contributors

* [@athaynes](https://github.com/athaynes) (Adam Haynes)
* [@bgouldman](https://github.com/bgouldman) (Brian Gouldman)
* [@camusicjunkie](https://github.com/camusicjunkie)
* [@chasewilson](https://github.com/chasewilson) (Chase Wilson)
* [@clcaldwell](https://github.com/clcaldwell) (Coby Caldwell)
* [@jcwalker](https://github.com/jcwalker) (Jason Walker)
* [@ldillonel](https://github.com/ldillonel)
* [@mcollera](https://github.com/mcollera)
* [@nehrua](https://github.com/nehrua) (Nehru Ali)
* [@regedit32](https://github.com/regedit32) (Reggie Gibson)
* [@llansey](https://github.com/llansey) (La'Neice Lansey)

## Versions

### Unreleased

* Added SkipRule functionality to all composite resources

### 2.0.0.0

* Added a Document module to automatically create a Stig Checklist (EXPERIMENTAL)
* Merged PowerStigDsc into PowerStig so there is only one module to maintain
  * Replaced PowerStig Technology Class with Enumeration
  * Added script module back to manifest
  * Added DotNetFramework composite resource

* Added the following STIGs
  * Windows Server 2012R2 MS STIG V2R13
  * Windows Server 2012R2 DC STIG V2R13
  * Windows 2012 DNS V1R10
  * Windows Domain V2R10
  * Windows Forest V2R8
  * IE11-V1R16

* Corrected parsing of rule V-46477 in the IE STIGs
  * Updated StigData
  * Bug fixes
  * Removed Windows Server 2012R2 MS and DC StigData v2.9

### 1.1.1.0

Update IIS Server STIG V-76723.a with correct value

### 1.1.0.0

Replaced Technology class with enumeration. This breaks PowerStigDsc < 1.1.0.0

Added the following STIGs:

* IIS 8.5 Server STIG V1R3

Updates

* Updated SQL STIG code to account for SQL STIGS being added in PowerStigDsc
* Update to PowerStig.psm1 to fix issue were StigData class was not accessible to PowerStigDsc

### 1.0.0.0

Added the following STIGs:

* Windows Server 2012R2 MS STIG V2R12
* Windows Server 2012R2 DC STIG V2R12
* Windows Server DNS V1R9
* Windows AD Domain V2R9
* IE11 V1R15
