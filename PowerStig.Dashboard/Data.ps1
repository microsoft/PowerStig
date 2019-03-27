
    $global:RuleTypeColors = ConvertFrom-StringData -StringData @'
        AccountPolicyRule = #F0F8FF
        AuditPolicyRule = #F0FFFF
        DocumentRule = #FF00FF
        DnsServerSettingRule = #006400
        FileContentRule = #228B22
        IisLoggingRule = #4B0082
        GroupRule = #FFD700
        ManualRule = #FF0000
        MimeTypeRule = #F5FFFA
        PermissionRule = #EEE8AA
        ProcessMitigationRule = #CD853F
        RegistryRule = #4169E1
        SecurityOptionRule = #C0C0C0
        ServiceRule = #87CEEB
        SqlScriptQueryRule = #6A5ACD
        SslSettingsRule = #00FF7F
        UserRightRule = #40E0D0
        WebAppPoolRule = #FFFFFF
        WebConfigurationPropertyRule = #FFFF00
        WindowsFeatureRule = #00008B
        WinEventLogRule = #FFA500
        WmiRule = #00FF00
'@
