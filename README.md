# PowerSTIG

|Branch|Status|
| ---- | ---- |
| master | [![Build status](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/master?svg=true)](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/master?svg=true) |
| dev | [![Build status](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/dev?svg=true)](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/dev?svg=true) |

## Project List

| Project Name | Decscription |
| ------------ | ------------ |
| [PowerStig](https://github.com/Microsoft/PowerStig) | A data module that other modules in the PowerStig project reference.
| [PowerStig.Tests](https://github.com/Microsoft/PowerStig.Tests) | A module that contains helper functions used across all pojects.
| [PowerStigDsc](https://github.com/Microsoft/PowerStigDsc) | A Composite DSC resource to apply and Audit STIG settings.

## Released Modules

To see a list of **all** released PowerStig modules, go to the [PowerShell Gallery](https://www.powershellgallery.com/items?q=powerstig&x=19&y=15).

We recommend that you use PowerShellGet to install PowerStig modules:

```powershell
Install-Module -Name < module name >
```

For example:

```powershell
Install-Module -Name PowerStig
```

To update a previously installed module use this command:

```powershell
Update-Module -Name PowerStig
```

## Contributing

You are more than welcome to contribute to the development of PowerStig.
There are several different ways you can help.
You can create new convert modules, add test automation, improve documentation, fix existing issues, or open new ones.
See our [contributing guide](CONTRIBUTING.md) for more info on how to become a contributor.

### Contributors

Thank you to everyone that has reviewed the project and provided feedback through issues.
We are especially thankful for those who have contributed pull requests to the code and documentation.

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

## Versions

### Unreleased

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
