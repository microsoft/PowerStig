# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# This is used to centralize the regEx patterns
data RegularExpression
{
    ConvertFrom-StringData -stringdata @'
        WinEventLogPath = Logs\\\\Microsoft\\\\Windows
'@
}
