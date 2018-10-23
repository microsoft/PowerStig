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

        spaceDashSpace = \\s-\\s

        TypePrincipalAccess = (?:\\bType\\b\\s*-\\s*\\w*\\s*)(?:\\bPrincipal\\b\\s*-\\s*(\\w*\\s*){1,2})(?:\\bAccess\\b\\s*-\\s*\\w*\\s*)

        InheritancePermissionMap = :\\(\\w\\)\\(\\w\\)

        PermissionRuleMap = \\(\\w\\)\\s*-\\s*\\w

        blankString = \\(Blank\\)

        nonLetters = [^a-zA-Z ]

        enabledOrDisabled = Enable(d)?|Disable(d)?

        # Windows Feature Rule Matches

        WindowsFeatureName = Get-WindowsFeature\\s-Name\\s*\\w+.\\w+

        FeatureNameEquals = FeatureName\\s-eq\\s*\\S*

        FeatureNameSpaceColon = FeatureName\\s\\:\\s\\S*

        IfTheApplicationExists = If the [\\s\\S]*?application exists

        WebDavPublishingFeature = ((W|w)eb(DAV|(D|d)av) (A|a)uthoring)|(WebDAV Publishing)

        SimpleTCP = Simple\\sTCP/IP\\sServices

        IISWebserver = Internet\\sInformation\\sServices

        IISHostableWebCore = Internet\\sInformation\\sServices\\sHostable\\sWeb\\sCore

        # Service policy matches

        McAfee = McAfee Agent

        SmartCardRemovalPolicy = Smart Card Removal Policy

        SecondaryLogon = Secondary Logon

        followingservices = Verify the Startup Type for the following Windows services:

        # DNS rules matches
        textBetweenTheTab = the\\s(?s)(.*)tab\\.

        allEvents = \\"All\\sevents\\"

        # Permission policy matches

        WinEvtDirectory = %SystemRoot%\\\\SYSTEM32\\\\WINEVT\\\\LOGS

        cDrive = system drive's root directory

        SysVol = Windows\\\\SYSVOL

        eventViewer = eventvwr\.exe

        systemRoot = Windows installation directory

        adminShares = (?=.*?\\bADMIN\\b\\$)(?=.*?\\bC\\b\\$)(?=.*?\\bIPC\\b\\$).*$

        permissionRegistryInstalled = (?=.*?\\bHKEY_LOCAL_MACHINE\\b)(?=.*?\\bInstalled\\sComponents\\b).*$

        permissionRegistryWinlogon = (?=.*?\\bHKEY_LOCAL_MACHINE\\b)(?=.*?\\bWinlogon\\b).*$

        permissionRegistryWinreg = (?=.*?\\bHKEY_LOCAL_MACHINE\\b)(?=.*?\\bwinreg\\b).*$

        permissionRegistryNTDS = (?=.*?\\bHKEY_LOCAL_MACHINE\\b)(?=.*?\\bNTDS\\b).*$

        programFiles = ^\\\\Program\\sFiles\\sand\\s\\\\Program\\sFiles\\s\\(x86\\)

        dnsServerLog = DNS\\sServer\\.evtx

        cryptoFolder = ^%ALLUSERSPROFILE%\\\\Microsoft\\\\Crypto$

        hklmSecurity = HKEY_LOCAL_MACHINE\\\\SECURITY

        hklmSoftware = HKEY_LOCAL_MACHINE\\\\SOFTWARE

        hklmSystem = HKEY_LOCAL_MACHINE\\\\SYSTEM

        hklmRootKeys = HKEY_LOCAL_MACHINE\\\\(SECURITY|SOFTWARE|SYSTEM)

        rootOfC = ^C\\:\\\\$

        winDir = ^\\\\Windows

        programFiles86 = ^\\\\Program\\sFiles\\s\\(x86\\)*

        programFileFolder = ^\\\\Program\\sFiles$

        # WinEventLog rule matches
        WinEventLogPath = Logs\\\\Microsoft\\\\Windows

        ADAuditPath = Verify the auditing configuration for (the)?

        inetpub = inetpub
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
