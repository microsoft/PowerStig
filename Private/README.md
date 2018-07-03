# PowerStigConvert

The PowerStigConvert project is part of the larger PowerSTIG solution to automate the delivery and auditing of the Security Technical Implementation Guide (STIG). This module is designed to convert the raw xccdf files provided by DISA and NIST into a usable data structure that can be directly consumed by additional automation. Right now, the primary target for the output of this module is a composite DSC Resource located [here](https://dodsig.visualstudio.com/PowerSTIG).

## Description

The purpose of this README file is to describe the structure and purpose of the private folder within the PowerStigConvert.

The private folder is where the project contains all of the STIG specific parsing data instructions for each STIG.

The breakdown of the folder structure is as follows:

-PowerStigConvert
--Private
---Common
---<STIG Specific Folder>

## Common

The common folder is a location for any functions or code that is shared 

## <STIG Specific Folder>

There should be 1 -> Many of these folders, a folder representing each of the STIGS that the ConverStigXccdf is capable of handling.  For example - if there is a folder called "Active Directory" then that folder should contain all of the specific logic for parsing and handing of the "Active Directory" STIG data.

## Functions

While writing the code to parse the STIGS and to avoid any collisions with other libraries, you will need to preface you functions as follows -

<verb> - PS <stig abrev> <action>

example:
Get-PSADRegistry
Set-PSADRegistry

Get PowerStig AD Registry
Set PowerStig AD Registry

## Why did we break it down like this

During the analysis phase of the project, the team discovered that while the STIGS are contained in a well-formed XML document, the content with the XML elements are written differently.  Periodically you will find the content of the "Fixit" element was written multiple ways within the STIG for a registry key. Another reason for breaking it out like this is for troubleshooting purposes.  At any given time if specific STIG is not being transformed correctly to the PowerSTIG.XML format, we know exactly where to start troubleshooting.
