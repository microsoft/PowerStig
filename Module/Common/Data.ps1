# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

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
