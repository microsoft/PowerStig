# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# This is used to validate strings and return the internal windows constant
data UserRightNameToConstant
{
    ConvertFrom-StringData -stringdata @'
        Access Credential Manager as a trusted caller = SeTrustedCredManAccessPrivilege
        Access this computer from the network = SeNetworkLogonRight
        Act as part of the operating system = SeTcbPrivilege
        Add workstations to domain = SeMachineAccountPrivilege
        Adjust memory quotas for a process = SeIncreaseQuotaPrivilege
        Allow log on locally = SeInteractiveLogonRight
        Allow log on through Remote Desktop Services = SeRemoteInteractiveLogonRight
        Allow log on through Terminal Services = SeRemoteInteractiveLogonRight
        Back up files and directories = SeBackupPrivilege
        Bypass traverse checking = SeChangeNotifyPrivilege
        Change the system time = SeSystemtimePrivilege
        Change the time zone = SeTimeZonePrivilege
        Create a pagefile = SeCreatePagefilePrivilege
        Create a token object = SeCreateTokenPrivilege
        Create global objects = SeCreateGlobalPrivilege
        Create permanent shared objects = SeCreatePermanentPrivilege
        Create symbolic links = SeCreateSymbolicLinkPrivilege
        Debug programs = SeDebugPrivilege
        Deny access to this computer from the network = SeDenyNetworkLogonRight
        Deny log on as a batch job = SeDenyBatchLogonRight
        Deny log on as a service = SeDenyServiceLogonRight
        Deny log on locally = SeDenyInteractiveLogonRight
        Deny log on through Remote Desktop Services = SeDenyRemoteInteractiveLogonRight
        Deny log on through Terminal Services  = SeDenyRemoteInteractiveLogonRight
        Enable computer and user accounts to be trusted for delegation = SeEnableDelegationPrivilege
        Force shutdown from a remote system = SeRemoteShutdownPrivilege
        Generate security audits = SeAuditPrivilege
        Impersonate a client after authentication = SeImpersonatePrivilege
        Increase a process working set = SeIncreaseWorkingSetPrivilege
        Increase scheduling priority = SeIncreaseBasePriorityPrivilege
        Load and unload device drivers = SeLoadDriverPrivilege
        Lock pages in memory = SeLockMemoryPrivilege
        Log on as a batch job = SeBatchLogonRight
        Log on as a service = SeServiceLogonRight
        Manage auditing and security log = SeSecurityPrivilege
        Modify an object label = SeRelabelPrivilege
        Modify firmware environment values = SeSystemEnvironmentPrivilege
        Perform volume maintenance tasks = SeManageVolumePrivilege
        Profile single process = SeProfileSingleProcessPrivilege
        Profile system performance = SeSystemProfilePrivilege
        Remove computer from docking station = SeUndockPrivilege
        Replace a process level token = SeAssignPrimaryTokenPrivilege
        Restore files and directories = SeRestorePrivilege
        Shut down the system = SeShutdownPrivilege
        Synchronize directory service data = SeSyncAgentPrivilege
        Take ownership of files or other objects = SeTakeOwnershipPrivilege
'@
}

# This is used to centralize the regEx patterns
data auditPolicySubcategories
{
    ConvertFrom-StringData -stringdata @'
        Security System Extension =
        System Integrity =
        IPsec Driver =
        Other System Events =
        Security State Change =
        Logon =
        Logoff =
        Account Lockout =
        IPsec Main Mode =
        IPsec Quick Mode =
        IPsec Extended Mode =
        Special Logon =
        Other Logon/Logoff Events =
        Network Policy Server =
        User / Device Claims =
        Group Membership =
        File System =
        Registry =
        Kernel Object =
        SAM =
        Certification Services =
        Application Generated =
        Handle Manipulation =
        File Share =
        Filtering Platform Packet Drop =
        Filtering Platform Connection =
        Other Object Access Events =
        Detailed File Share =
        Removable Storage =
        Central Policy Staging =
        Non Sensitive Privilege Use =
        Other Privilege Use Events =
        Sensitive Privilege Use =
        Process Creation =
        Process Termination =
        DPAPI Activity =
        RPC Events =
        Plug and Play Events =
        Authentication Policy Change =
        Authorization Policy Change =
        MPSSVC Rule-Level Policy Change =
        Filtering Platform Policy Change =
        Other Policy Change Events =
        Audit Policy Change =
        User Account Management =
        Computer Account Management =
        Security Group Management =
        Distribution Group Management =
        Application Group Management =
        Other Account Management Events =
        Directory Service Changes =
        Directory Service Replication =
        Detailed Directory Service Replication =
        Directory Service Access =
        Kerberos Service Ticket Operations =
        Other Account Logon Events =
        Kerberos Authentication Service =
        Credential Validation =
'@
}

# Audit policy matches
data auditPolicyFlags
{
    ConvertFrom-StringData -stringdata @'
        Success =
        Failure =
'@
}

# This is used to centralize the regEx patterns
data auditPolicyRegularExpressions
{
    ConvertFrom-StringData -stringdata @'
    AuditPolicyLine  = (-|>)> (.*?) -
    AuditPolicySplit = >>|->|-
'@
}

# This is used to centralize the regEx patterns
data RegularExpression
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

data ADAuditPath
{
    ConvertFrom-StringData -StringData @'
        domain = {Domain}
        Domain Controller OU = OU=Domain Controllers,{Domain}
        AdminSDHolder = CN=AdminSDHolder,CN=System,{Domain}
        RID Manager$ = CN=RID Manager$,CN=System,{Domain}
        Infrastructure = CN=Infrastructure,{Domain}
'@
}

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

data DnsServerSetting
{
    ConvertFrom-StringData @'
        Event Logging = EventLogLevel
        Forwarders    = NoRecursion

'@
}

data fileRightsConstant
{
    ConvertFrom-StringData -StringData @'
        Full Control                        = FullControl
        full access                         = FullControl
        Read                                = Read
        Modify                              = Modify
        Read & execute                      = ReadAndExecute
        Read and execute                    = ReadAndExecute
        Create folders                      = CreateDirectories
        append data                         = AppendData
        Create files                        = CreateFiles
        write data                          = WriteData
        list folder contents                = ListDirectory
        all selected except Full control    = AppendData,ChangePermissions,CreateDirectories,CreateFiles,Delete,DeleteSubdirectoriesAndFiles,ExecuteFile,ListDirectory,Modify,Read,ReadAndExecute,ReadAttributes,ReadData,ReadExtendedAttributes,ReadPermissions,Synchronize,TakeOwnership,Traverse,Write,WriteAttributes,WriteData,WriteExtendedAttributes
'@
}

data registryRightsConstant
{
    ConvertFrom-StringData -StringData @'
        Full Control   = FullControl
        Read           = ReadKey
'@
}

data activeDirectoryRightsConstant
{
    ConvertFrom-StringData -StringData @'
        Full Control                    = FullControl
        full access                     = FullControl
        Write all properties            = WriteallProperties
        All extended rights             = AllExtendedRights
        Change infrastructure master    = ChangeInfrastructureMaster
        Modify Permissions              = ModifyPermissions
        Modify Owner                    = ModifyOwner
        Change RID master               = ChangeRIDMaster
        all create                      = Createallchildobjects
        delete and modify permissions   = Delete,ModifyPermissions
        (blank)                         = blank
'@
}

data inheritenceConstant
{
    ConvertFrom-StringData -StringData @'
        This key and subkeys                    = This Key and Subkeys
        This key only                           = This Key Only
        Subkeys only                            = Subkeys Only
        This folder and subfolders              = This folder and subfolders
        This folder only                        = This folder only
        Subfolders and files only               = Subfolders and files only
        This folder, subfolders and files       = This folder subfolders and files
        This folder, subfolder and files        = This folder subfolders and files
        Subfolders only                         = Subfolders only
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
