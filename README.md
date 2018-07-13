# PowerSTIG

master: [![Build status](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/master?svg=true)](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/master?svg=true)

dev: [![Build status](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/dev?svg=true)](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/dev?svg=true)

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
See our [contributing guide](https://github.com/Microsoft/PowerStig/blob/master/CONTRIBUTING.md) for more info on how to become a DSC Resource Kit contributor.

## Versions

### Unreleased

### 1.0.0.0

Added the following STIGs:

* Windows Server 2012R2 MS STIG V2R12
* Windows Server 2012R2 DC STIG V2R12
* Windows Server DNS V1R9
* Windows AD Domain V2R9
* IE11 V1R15
