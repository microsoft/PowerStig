# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    This is used to centralize the regEx patterns, note that the backslashes are
    escaped, a single "\s" would be represented as "\\s"
#>
data regularExpression
{
    ConvertFrom-StringData -StringData @'
        nxServiceName    = (sudo)? systemctl \\w*\\s*(?'serviceName'(\\w*(\\.?))+)
        nxServiceState   = (sudo)? systemctl (?'serviceState'(restart|start|stop))
        nxServiceEnabled = (sudo)? systemctl (?'serviceEnabled'(enable|disable))
'@
}
