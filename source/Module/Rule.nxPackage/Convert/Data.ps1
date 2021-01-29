# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    This is used to centralize the regEx patterns, note that the backslashes are
    escaped, a single "\s" would be represented as "\\s"
#>
data regularExpression
{
    ConvertFrom-StringData -StringData @'
        nxPackage = #\\s*((sudo)? apt(-get)?|yum)\\s+(?<packageState>install|remove)\\s*(?<packageName>(\\w*(-?))+)
'@
}
