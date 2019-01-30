# Versions

## Unreleased

* Fixed [#244](https://github.com/Microsoft/PowerStig/issues/244): IIS Server rule V-76727.b org setting test fails

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
