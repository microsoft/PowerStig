data xmlAttribute
{
    ConvertFrom-StringData -stringdata @'

    stigId               = id
    stigVersion          = version
    stigConvertCreated   = created

    ruleId                  = id
    ruleSeverity            = severity
    ruleConversionStatus    = conversionstatus
    ruleTitle               = title
    ruleDscResource         = dscresource
    ruleDscResourceModule   = dscresourcemodule

    organizationalSettingValue = value
'@
}

data xmlElement
{
    ConvertFrom-StringData -stringdata @'

    stigConvertRoot = DISASTIG

    organizationalSettingRoot  = OrganizationalSettings
    organizationalSettingChild = OrganizationalSetting
'@
}
