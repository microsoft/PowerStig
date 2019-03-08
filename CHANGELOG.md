# Versions

## 3.0.0

UPDATES

* Fixed [#350](https://github.com/Microsoft/PowerStig/issues/350): Updates to fix Skip rules not working correctly

## 3.0.0

* Introduces class support for each rule type
* The STIG class now contains an array of rule objects vs xml elements
* Orgsettings, Exceptions, and Rule skips are all supported by the Rule base class
* Rule help is provided for any loaded rule.
  * See the [wiki](https://github.com/Microsoft/PowerStig/wiki/GettingRuleHelp) for more information.
* Major code refactor to simplify maintenance and usage
* [Breaking Change] The STIG class constructor no longer accepts Orgsettings, Exceptions, or Rule skips
  * That functionality has move to the load rule method
* DSC composite resource parameter validation for version numbers has been removed
  * The STIG class validates all input and will throw an error if invalid data is provided.
* The Get-StigList has be updated and renamed to Get-Stig to return the STIG class

UPDATES

* Fixed [#241](https://github.com/Microsoft/PowerStig/issues/241): [WindowsFeatureRule] PsDesiredStateConfiguration\WindowsOptionalFeature doesn't properly handle features that return $null
* Fixed [#258](https://github.com/Microsoft/PowerStig/issues/258): New-StigChecklist will not accept a path without an explicit filename
* Fixed [#243](https://github.com/Microsoft/PowerStig/issues/243): [V-46515] Windows-All-IE11-1.15 Rawstring typo
* Fixed [#289](https://github.com/Microsoft/PowerStig/issues/289): Updated DocumentRule and DocumentRuleConvert Classes to parse correctly.
* Fixed [#284](https://github.com/Microsoft/PowerStig/issues/284): [V-74415] [V-74413] Windows 10 STIG rule V-74415 and V-74413 should not contain white space in key
* Fixed [290](https://github.com/Microsoft/PowerStig/issues/290): [V-76731] IIS Server STIG V-76731 fails to properly set STIG guidance because rule is not split.
* Fixed [314](https://github.com/Microsoft/PowerStig/issues/314): Update PowerSTIG to Utilize LogTargetW3C parameter in xWebAdministration 2.5.0.0.
* Fixed [334](https://github.com/Microsoft/PowerStig/issues/334): Update PowerStig to utilize AccessControlDsc 1.3.0.0
* Fixed [331](https://github.com/Microsoft/PowerStig/issues/331): 2012/R2 [V-39325] 2016 [V-73373], [V-73389] PermissionRule.Convert CheckContent Match Parser Update
* Fixed [320](https://github.com/Microsoft/PowerStig/issues/320): IIS Site STIG doesn't correctly convert STIGS that contain "SSL Settings" in raw string

* Added the following STIGs
  * IIS Site 8.5 V1R6 [#276](https://github.com/Microsoft/PowerStig/issues/276)
  * Windows Firewall STIG V1R7 [#319](https://github.com/Microsoft/PowerStig/issues/319)

* Removed the following STIGs
  * Windows Server 2012 R2 DC 2.12
  * Windows Server 2012 R2 DSN 1.7
  * Active Directory Domain 2.9
  * IIS Server 8.5 1.3
  * IIS Site 8.5 1.2
  * Removed: Internet Explorer 1.13

## 2.4.0.0

* Fixed [#244](https://github.com/Microsoft/PowerStig/issues/244): IIS Server rule V-76727.b org setting test fails
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
  * Windows Server 2012R2 DNS V1R11 STIG [#265](https://github.com/Microsoft/PowerStig/issues/265)
  * AD Domain V2R12 [#270](https://github.com/Microsoft/PowerStig/issues/270)

## 2.3.2.0

* Fixed [#215](https://github.com/Microsoft/PowerStig/issues/215): Org settings wont apply for DotNet STIG
* Fixed [#216](https://github.com/Microsoft/PowerStig/issues/216): DotNet STIGs are misnamed
* Fixed [#207](https://github.com/Microsoft/PowerStig/issues/207): SQL Server Database rules fail to apply
* Fixed [#208](https://github.com/Microsoft/PowerStig/issues/208): Update PowerSTIG to use SQLServerDsc 12.1.0.0
* Fixed [#220](https://github.com/Microsoft/PowerStig/issues/220): Update PowerSTIG to use xWebAdministration 2.3.0.0

## 2.3.1.0

* Fixed [#212](https://github.com/Microsoft/PowerStig/issues/212): SDDL strings are incorrectly split in the xRegistry resource
* Fixed [#180](https://github.com/Microsoft/PowerStig/issues/180): IisSite SkipRuleType and SkipRule fail to skip rules

## 2.3.0.0

* Windows 10 Fixes
  * V-63795 - Changed from manual to registry rule ## HIGH IMPACT CHANGE ##

* Windows Server 2012R2 Fixes
  * V-1089 - Corrected text
  * V-21954 - Changed from manual to registry rule ## HIGH IMPACT CHANGE ##
  * V-26070 - Corrected key path
  * V-36657 - Corrected key path
  * V-36681 - Corrected key path

* Added the following STIGs
  * IIS Server 8.5 STIG V1R5
  * Microsoft Outlook 2013 STIG V1R13
  * DotNet Framework 4.0 STIG V1R6
  * IIS Site 8.5 STIG V1R5
  * Windows Domain V2R11
  * FireFox 4.23 STIG
  * Windows Server 2012R2 DC V2R14
  * Windows Server 2012R2 MS V2R14
  * Windows 10 V1R15

## 2.2.0.0

* Added the following STIGs
  * IIS Site 8.5 STIG V1R2
  * IIS Site 8.5 STIG V1R3
  * Oracle JRE 8 STIG V1R5
  * Microsoft Outlook 2013 STIG V1R12
  * Microsoft PowerPoint 2013 Stig V1R6
  * Microsoft Excel 2013 STIG V1R7
  * Microsoft Word 2013 STIG V1R6

* Added the following DSC Composite Resources
  * Microsoft Office 2013 STIGs
  * FireFox STIG
  * IIS Site STIG
  * IIS Server STIG
  * Oracle JRE STIG
  * Windows10 STIG

* Newly required modules
  * PolicyFileEditor
  * FileContentDsc
  * WindowsDefenderDSC
  * xWebAdministration
  * xWinEventLog

* Updated required module versions
  * xDnsServer from 1.9.0.0 to 1.11.0.0
  * SecurityPolicyDsc from 2.2.0.0 to 2.4.0.0

## 2.1.0.0

* Migrated Composite resources to the xRegistry resource
* Fixed 2012R2 V-15713 default org setting value
* Updated IE STIGs (V-46477) with the decimal value
* Updated New-StigCheckList to output StigViewer 2.7.1 ckl files
* Added SkipRule functionality to all composite resources
* Added StigData for FireFox STIG V4R21
* Added Sql2012 1.17 to Archive and processed
* Updated Sql2012 1.16 to fix broken rules
* Removed Sql2012 1.14 from archives to comply with n-2 version policy
* Updated data for 2012R2 Stigs to fix broken rules

## 2.0.0.0

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

## 1.1.1.0

Update IIS Server STIG V-76723.a with correct value

## 1.1.0.0

Replaced Technology class with enumeration. This breaks PowerStigDsc < 1.1.0.0

Added the following STIGs:

* IIS 8.5 Server STIG V1R3

Updates

* Updated SQL STIG code to account for SQL STIGS being added in PowerStigDsc
* Update to PowerStig.psm1 to fix issue were StigData class was not accessible to PowerStigDsc

## 1.0.0.0

Added the following STIGs:

* Windows Server 2012R2 MS STIG V2R12
* Windows Server 2012R2 DC STIG V2R12
* Windows Server DNS V1R9
* Windows AD Domain V2R9
* IE11 V1R15
