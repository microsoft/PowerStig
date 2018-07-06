# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

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

data logflagsConstant
{
    ConvertFrom-StringData -stringdata @'
        Client IP Address = ClientIP
        Date              = Date
        Method            = Method
        Protocol Status   = ProtocolVersion
        Referrer          = Referer
        and Referrer      = Referer
        Time              = Time
        URI Query         = UriQuery
        User Agent        = UserAgent
        User Name         = UserName
'@
}
