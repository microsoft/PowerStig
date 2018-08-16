# PowerSTIG

**PowerStig** is a PowerShell module that contains several components to automate different DISA Security Technical Implementation Guides (STIGs) where possible.

1. A module to extract settings from check-content elements of the xccdf
1. Parsed Stig data that can be used by other components of this module or additional automation
1. A module with PowerShell classes to provide a way of retrieving the parsed STIG data and documenting deviations
    1. Provides a method to apply exceptions to a setting
    1. Provides a method to exclude a rule
    1. Provides a method to exclude an entire class of rules
1. Windows PowerShell Desired State Configuration (DSC) composite resources to manage the configurable items
1. A module to create checklists and other types of documentation (Coming soon)

This project has adopted the [Microsoft Open Source Code of Conduct](
  https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](
  https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions
or comments.

|Branch|Status|Description|
| ---- | ---- | --- |
| master | [![Build status](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/master?svg=true)](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/master?svg=true) | Ccontains the latest release - no contributions should be made directly to this branch. |
| dev | [![Build status](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/dev?svg=true)](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/dev?svg=true) | Where contributions should be proposed by contributors as pull requests. This branch is merged into the master branch, and be released to [PowerShell Gallery](https://www.powershellgallery.com/). |

## Released Module

To see the released PowerStig module, go to the [PowerShell Gallery](https://www.powershellgallery.com/items?q=powerstig&x=19&y=15). We recommend that you use PowerShellGet to install PowerStig:

For example:

```powershell
Install-Module -Name PowerStig
```

To update a previously installed module use this command:

```powershell
Update-Module -Name PowerStig
```

## Composite Resources

* [Browser](https://github.com/Microsoft/PowerStigDsc/wiki/Browser): Provides a mechanism to manage Browser STIG settings.

* [DotNetFramework](https://github.com/Microsoft/PowerStigDsc/wiki/DotNetFramework): Provides a mechanism to manage .Net Framework STIG settings.

* [SqlServer](https://github.com/Microsoft/PowerStigDsc/wiki/SqlServer): Provides a mechanism to manage SqlServer STIG settings.

* [WindowsDnsServer](https://github.com/Microsoft/PowerStigDsc/wiki/WindowsDnsServer): Provides a mechanism to manage Windows DNS Server STIG settings.

* [WindowsFirewall](https://github.com/Microsoft/PowerStigDsc/wiki/WindowsFirewall): Provides a mechanism to manage the Windows Firewall STIG settings.

* [WindowsServer](https://github.com/Microsoft/PowerStigDsc/wiki/WindowsServer): Provides a mechanism to manage the Windows Server STIG settings.

## Contributing

You are more than welcome to contribute to the development of PowerStig.
There are several different ways you can help.
You can create new convert modules, add test automation, improve documentation, fix existing issues, or open new ones.
See our [contributing guide](CONTRIBUTING.md) for more info on how to become a contributor.
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
* [@llansey] (https://github.com/llansey) (La'Neice Lansey)

## Versions

### Unreleased

* Merged PowerStigDsc into PowerStig so there is only one module to maintain
  * Replaced PowerStig Technology Class with Enumeration
  * Added script module back to manifest
  * Added DotNetFramework composite resource

Added the following STIGs:

* Windows Server 2012R2 MS STIG V2R13
* Windows Server 2012R2 DC STIG V2R13
* Windows 2012 DNS V1R10
* Windows Domain V2R10
* Windows Forest V2R8
* IE11-V1R16

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
