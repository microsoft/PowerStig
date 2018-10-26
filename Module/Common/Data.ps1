# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# This is used to centralize the regEx patterns
data rangeMatch
{
    ConvertFrom-StringData -stringdata @'
        gt = ^0x([A-Fa-f0-9]{8})
        ge = ^[0-9]{1,}
        lt =  or less
        less than = lt
        or less   = lt
        le = '(.*?)'
'@
}

data errorMessage
{
    ConvertFrom-StringData -stringdata @'
        ruleNotFound    = rule not found
        ruleNotComplete = rule not complete
'@
}

data processMitigationRegex
{
    ConvertFrom-StringData -StringData @'
        TextBetweenDoubleQuoteAndColon = "[\\s\\S]*?:
        TextBetweenColonAndDoubleQuote = :[\\s\\S]*?"
        EnableColon        = Enable:
        ColonSpaceOn       = :\\sON
        IfTheStatusOf      = If\\sthe\\sstatus\\sof
        IfTheStatusOfIsOff = If\\sthe\\sstatus\\sof[\\s\\S]*?\\sis\\s"OFF"[\\s\\S]*this\\sis\\sa\\sfinding
        NotHaveAStatusOfOn = If\\sthe\\sfollowing\\smitigations\\sdo\\snot\\shave\\sa\\sstatus\\sof\\s"ON"
'@
}

# List rules that can be excluded
data exclusionRuleList
{
    ConvertFrom-StringData -StringData @'
        V-73523 =
'@
}

data webRegularExpression
{
    ConvertFrom-StringData -stringdata @'
        configSection           = (?<=\")system.+?(?=\")
        customFields            = >>
        customFieldSection      = Under "Custom Fields", verify the following fields
        excludeExtendedAscii    = [^\x20-\x7A]+
        keyValuePairLine        = Verify.+?(reflects|is set to)
        keyValuePair            = (?<=\").+?(?=\")
        logFlags                = (?<=(")?Select Fields(")?, verify at a minimum the following fields are checked:).+(?=\.)
        logFormat               = Verify the "Format:" under "Log File" is configured to
        logPeriod               = Verify a schedule is configured to rollover log files
        logTargetW3c            = Under Log Event Destination, verify the
        mimeType                = (?<=)^[.].+(?=)
        mimeTypeAbsent          = verify MIME types for OS shell program extensions have been removed
        standardFields          = (?<=Under "Standard Fields",).+
        standardFieldEntries    = "([^"]*)"
        HMACSHA256              = Verify "HMACSHA256" is selected for the Validation method
        autoEncryptionMethod    = "Auto" is selected for the Encryption method
        CGIModules              = "Allow unspecified CGI modules"
        ISAPIModules            = "Allow unspecified ISAPI modules"
        useCookies              = (Use Cookies|UseCookies)
        expiredSession          = Regenerate expired session ID
        sessionTimeout          = Time\-out
'@
}


