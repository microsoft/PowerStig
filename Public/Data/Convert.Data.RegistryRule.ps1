# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# These are the registry types that are accepted by the registry DSC resource
data dscRegistryValueType
{
    ConvertFrom-StringData -stringdata @'
        REG_SZ         = String
        REG_BINARY     = Binary
        REG_DWORD      = Dword
        REG_QWORD      = Qword
        REG_MULTI_SZ   = MultiString
        REG_EXPAND_SZ  = ExpandableString
        Does Not Exist = Does Not Exist
        DWORD          = Dword
'@
}

data registryRegularExpression
{
    ConvertFrom-StringData -stringdata @'

        # the registry hive is not provided in a consistant format, so the search pattern needs
        # to account for optional character ranges
        registryHive = (Registry)?\\s?Hive\\s?:\\s*?(HKEY_LOCAL_MACHINE|HKEY_CURRENT_USER)

        #registryPath      = ((Registry)?\\s*(Path|SubKey)\\s*:\\s*|^\\\\SOFTWARE)(\\\\)?\\w+(\\\\)\\w+(\\\\)?

        registryPath      = ((Registry)?\\s*(Path|SubKey)\\s*:\\s*|^\\\\SOFTWARE)(\\\\)?\\w+(\\\\)(\\w+(\\\\)?|\\sP)

        registryEntryType = Type\\s?:\\s*?REG_(SZ|BINARY|DWORD|QWORD|MULTI_SZ|EXPAND_SZ)(\\s{1,}|$)

        registryValueName = ^\\s*?Value\\s*?Name\\s*?:

        registryValueData = ^\\s*?Value\\s*?:
        # extracts multi string values
        MultiStringNamedPipe = (?m)(^)(System|Software)(.+)$

        # or is in a word boundary since it is a common pattern
        registryValueRange = (?<![\\w\\d])but|\\bor\\b|and|Possible values(?![\\w\\d])

        # this is need validate that a value is still a string even if it contains a number
        hardenUncPathValues = (RequireMutualAuthentication|RequireIntegrity)
'@
}
