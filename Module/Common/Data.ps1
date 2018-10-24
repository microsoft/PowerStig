# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# This is used to centralize the regEx patterns
data commonRegEx
{
    ConvertFrom-StringData -stringdata @'
        # General matches

        dash = -

        # match a exactly one ( the first ) hexcode in a string
        hexCode = \\b(0x[A-Fa-f0-9]{8}){1}\\b

        # looks for an integer but is not hex
        leadingIntegerUnbound = \\b([0-9]{1,})\\b

        textBetweenQuotes = ["\''](.*?)["\'']

        textBetweenParentheses = \\(([^\)]+)\\)

        blankString = \\(Blank\\)

        nonLetters = [^a-zA-Z ]

        enabledOrDisabled = Enable(d)?|Disable(d)?

        # DNS rules matches
        textBetweenTheTab = the\\s(?s)(.*)tab\\.

        allEvents = \\"All\\sevents\\"

        # WinEventLog rule matches
        WinEventLogPath = Logs\\\\Microsoft\\\\Windows
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
        inetpub                 = inetpub
'@
}

# List rules that can be excluded
data exclusionRuleList
{
    ConvertFrom-StringData -StringData @'
        V-73523 =
'@
}
