# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    This is used to centralize the regEx patterns, note that the backslashes are
    escaped, a single "\s" would be represented as "\\s"
#>
data regularExpression
{
    ConvertFrom-StringData -StringData @'
        nxServiceName    = (sudo)?\\s*systemctl\\s+\\w*\\s*(?<serviceName>(\\w*(\\.?))+)
        nxServiceState   = (sudo)?\\s*systemctl\\s+(?<serviceState>(restart|start|stop))
        nxServiceEnabled = (sudo)?\\s*systemctl\\s+(?<serviceEnabled>(enable|disable|start))
'@
}
