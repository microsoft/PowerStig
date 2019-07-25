# PowerSTIG Archive log file

* I have talked a little bit about starting to modify the xccdf files to fix minor issues in the content the DISA provides.
* The initial idea was to manually update the xccdf and keep a record of the change in a markdown file. ID::OldText::NewText
* I realized that this is not a great solution, due to not being 100% sure what the original text was.
* Let's automate

## Challenge

* It feels like there is a conspiracy at DISA to make PowerSTIG parser a PIA to maintain.
* I keep seeing Issues opened to update the parser for the latest STIG X
* No easy way to fix Spelling \ Formatting issues

## Purposed solution

* Take the original idea and automate it now before we make a bunch of changes that we have to undo later.
* The change log is now an active file that is used during the parsing process.

## How it works

1. The code looks for a .log file with the same full path as the xccdf.
1. Each line is in the following format ID::OldText::NewText
    1. Multiple entries per rule are supported
    1. The asterisk "*" can be used to replace everything in the check-content
1. The log content is converted into a hashtable
1. Before a rule is processed, the check-content string is updated using a replace OldText > NewText.
1. The rule is parsed and returned
1. The RawString is then updated to undo the log file change NewText > OldText.

This allows us to inject the rule intent without having to dig into the xml or update the parser.
We have most of the general patterns ironed out and now we are just dealing with random formatting\ spelling charges.
We need to take the time to determine when the change needs to be made, because we don't necessarily want to end up with a log file entry for each rule either.

## HardCodedRule automation through specially crafted log entries

### Challenge (HardCodedRule)

* It is nearly impossible to automate 100% of all STIG Rules through parsing Fix Text or Check Content.
* Leverage as much of the PowerSTIG Convert framework to promote code efficiency.

### Purposed solution (HardCodedRule)

* PowerSTIG Convert/Parser Changes:
  * Leverage the STIG log file framework to pass input directly to the ConvertFactory (Parser) in order to create the correct RuleType.
  * Update the creation of _\<StigFullName>_.org.default.xml, a.k.a. **OrgSettings file**, to include property names where the value is **$null**
* STIG Class / .mof Compilation Changes:
  * Extend the OrgSettings file, to accept multiple values for a given rule during mof compilation.
  * Extend the SkipRule usage when rule property values in the OrgSettings File are blank **(\[string]::Empty)**
    * Send a SkipRule warning to the user during mof compilation when values in the OrgSettings file are blank.

### How it works (HardCodedRule)

1. When the xccdf is imported, the log file framework replaces the entire Check Content property with a specially crafted HardCodedRule string.
2. When the ConvertTo-PowerStigXml function is called, it imports the xccdf and the log file, performs the Check Content replacement and then begins parsing.
3. If the parser encounters a Check Content block that begins with **HardCodedRule**, it is redirected to the **HardCodedRuleConvert** class. Based on the Check Content string, the **HardCodedRuleConvert** class determines the RuleType, DscResource and Parameters with possible values.
4. When the RuleType, DscResource and Parameters are identified, the **HardCodedRuleConvert** class creates the specified rule type object, then assigns the defined values.
5. If any values are not defined during this process, the rule property **OrganizationValueRequired** will be set to **true** and any null value property will be added to the OrgSettings file for consumption during mof compilation.
6. HardCodedRule Log Entry Rules:
    1. Single HardCodedRule entries follow these rules:
        1. The replacement string should start with **HardCodedRule**, i.e.: **V-1000::*::HardCodedRule**
        1. Followed by the **RuleType** within parentheses, i.e.: **(WindowsFeatureRule)**
        1. Followed by a hashtable which represents the DscResource and associated properties to be defined, i.e.: **@{DscResource = 'WindowsFeature'; Name = 'Web-Ftp-Server'; Ensure = 'Absent'}**
            1. If any property value should be defined by the user, then ensure that specific property value is set to $null, i.e.: **@{DscResource = 'WindowsFeature'; Name = $null; Ensure = 'Absent'}**
                1. This will set the **OrganizationValueRequired** property to **true** for the rule, as well as an empty entry in the OrgSettings file after parsing completes
        1. Examples:
            1. Fully Defined/No OrgSetting Entry: **V-1000::*::HardCodedRule(WindowsFeatureRule)@{DscResource = 'WindowsFeature'; Name = 'Web-Ftp-Server'; Ensure = 'Absent'}**
            1. User Defined _Name_ property/With OrgSetting Entry: **V-1000::*::HardCodedRule(WindowsFeatureRule)@{DscResource = 'WindowsFeature'; Name = $null; Ensure = 'Absent'}**
    2. Creating split rules for a specific RuleId follows the **Single HardCodedRule Entry** rules with a special delimiter: **\<splitRule>**
        1. Example:
            1. Fully Defined: **V-1000::*::HardCodedRule(WindowsFeatureRule)@{DscResource = 'WindowsFeature'; Name = 'Web-Ftp-Server'; Ensure = 'Absent'}\<splitRule>HardCodedRule(ServiceRule)@{DscResource = 'Service'; Ensure = 'Present'; ServiceName = 'NTDS'; ServiceState = 'Running'; StartupType = 'Automatic'}**
            2. User Defined _StartupType_ property: **V-1000::*::HardCodedRule(WindowsFeatureRule)@{DscResource = 'WindowsFeature'; Name = 'Web-Ftp-Server'; Ensure = 'Absent'}\<splitRule>HardCodedRule(ServiceRule)@{DscResource = 'Service'; Ensure = 'Present'; ServiceName = 'NTDS'; ServiceState = 'Running'; StartupType = $null}**
    3. To assist with creating the HardCodedRule strings, the **Get-HardCodedRuleLogFileEntry** function will generate a string based parameters supplied to it. For example, if two split rules (WindowsFeatureRule/ServiceRule) should be created for RuleId V-1000, then the following can be used:
        1. **Get-HardCodedRuleLogFileEntry -RuleId V-1000 -RuleType WindowsFeatureRule, ServiceRule**
        2. OutPut: **V-1000::*::HardCodedRule(WindowsFeatureRule)@{DscResource = 'WindowsFeature'; Ensure = $null; Name = $null}<splitRule>HardCodedRule(ServiceRule)@{DscResource = 'Service'; Ensure = $null; ServiceName = $null; ServiceState = $null; StartupType = $null}**

### Caveats (HardCodedRule)

* To be addressed in a future release:
  * DscResource Property Values cannot be nested, for example, a PSObject or Hashtable cannot be passed as a value from the log file. This may occur when trying to leverage a PermissionRule or IISLoggingRule, specifically the AccessControlEntry and LogCustomFieldEntry properties from these two parameters require a nested object.
  * Once a RuleId is defined as a HardCodedRule, then it can only be a HardCodedRule. For example, if the parser works correctly to parse a rule a certain way, a split rule cannot be added as a HardCodedRule.
