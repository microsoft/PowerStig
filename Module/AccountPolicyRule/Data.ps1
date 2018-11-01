# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
# Account policy name fixes
data policyNameFixes
{
    ConvertFrom-StringData -stringdata @'
        Minimum password length,                   = Minimum password length
        Store password using reversible encryption = Store passwords using reversible encryption
'@
}
